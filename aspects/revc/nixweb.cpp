// Web remote for the trainer + debug menu (see nixweb.h for the overview).
//
// A background thread serves a self-contained phone UI over plain HTTP and
// exposes two JSON endpoints:
//
//   GET  /            the embedded single-page UI
//   GET  /api/state   full menu tree + current values
//   POST /api/act     body "id=<hex>&op=set|trigger&val=<num>"
//
// The HTTP thread owns no game state: /api/state parks on a condition
// variable until the game thread publishes the next snapshot, and /api/act
// enqueues the action and then waits for that same snapshot, so every
// response reflects the world after the action ran. If the game loop is not
// pumping (still on the frontend), the wait times out and the UI shows a
// "waiting for game" state instead.
//
// Port: 8766 by default, overridden by REVC_WEB_PORT (0 disables). Binds all
// interfaces; on NixOS only SSH/tailnet traffic passes the firewall.

#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>

#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#include <chrono>
#include <condition_variable>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

#include "common.h"
#include "nixcheats.h"

#ifdef DEBUGMENU

#include "World.h"
#include "debugmenu.h"
#include "nixweb.h"

#define NIX_WEB_DEFAULT_PORT 8766
// How long a request waits for the game thread to publish a snapshot before
// reporting "not ready". Covers pathologically slow frames with room to spare.
#define NIX_WEB_SNAPSHOT_TIMEOUT_MS 2000

enum NixWebOp {
	NIXWEB_OP_SET,
	NIXWEB_OP_TRIGGER,
};

struct NixWebCmd {
	void *id;
	int op;
	double val;
};

static std::mutex gNixWebMutex;
static std::condition_variable gNixWebCv;
static std::vector<NixWebCmd> gNixWebCmds; // guarded by gNixWebMutex
static bool gNixWebWantState = false;      // guarded by gNixWebMutex
static uint64_t gNixWebStateGen = 0;       // guarded by gNixWebMutex
static std::string gNixWebStateJson;       // guarded by gNixWebMutex

// ---------------------------------------------------------------------------
// Game thread: snapshot serialization
// ---------------------------------------------------------------------------

static void
nixWebJsonEscape(std::string &out, const char *s)
{
	for(; *s; s++){
		unsigned char c = *s;
		if(c == '"' || c == '\\'){
			out += '\\';
			out += (char)c;
		}else if(c < 0x20){
			char buf[8];
			snprintf(buf, sizeof(buf), "\\u%04x", c);
			out += buf;
		}else
			out += (char)c;
	}
}

static void
nixWebAppendEntry(const NixDbgEntryInfo *info, void *user)
{
	std::string &out = *(std::string*)user;
	char buf[160];

	if(out[out.size()-1] != '[')
		out += ',';

	snprintf(buf, sizeof(buf), "{\"id\":\"%" PRIxPTR "\",\"path\":\"", (uintptr_t)info->id);
	out += buf;
	nixWebJsonEscape(out, info->path);
	out += "\",\"name\":\"";
	nixWebJsonEscape(out, info->name);
	out += "\",\"kind\":\"";
	out += info->kind == NIXDBG_CMD ? "cmd" : info->kind == NIXDBG_FLOAT ? "float" : "int";
	out += '"';

	if(info->kind != NIXDBG_CMD){
		snprintf(buf, sizeof(buf),
			",\"val\":%.9g,\"min\":%.9g,\"max\":%.9g,\"step\":%.9g,\"wrap\":%s",
			info->value, info->lower, info->upper, info->step,
			info->wrap ? "true" : "false");
		out += buf;
		if(info->strings){
			out += ",\"choices\":[";
			for(int i = 0; i < info->nstrings; i++){
				if(i) out += ',';
				out += '"';
				nixWebJsonEscape(out, info->strings[i]);
				out += '"';
			}
			out += ']';
		}
	}
	out += '}';
}

static void
nixWebBuildState(std::string &out, bool ingame)
{
	out.clear();
	out.reserve(64*1024);
	out += ingame ? "{\"ready\":true,\"ingame\":true,\"entries\":["
	              : "{\"ready\":true,\"ingame\":false,\"entries\":[";
	NixDbgWalk(nixWebAppendEntry, &out);
	out += "]}";
}

// ---------------------------------------------------------------------------
// HTTP thread: snapshot/action exchange with the game thread
// ---------------------------------------------------------------------------

static bool
nixWebAwaitState(std::string &out)
{
	std::unique_lock<std::mutex> lk(gNixWebMutex);
	uint64_t gen = gNixWebStateGen;
	gNixWebWantState = true;
	bool fresh = gNixWebCv.wait_for(lk,
		std::chrono::milliseconds(NIX_WEB_SNAPSHOT_TIMEOUT_MS),
		[&]{ return gNixWebStateGen != gen; });
	if(fresh)
		out = gNixWebStateJson;
	return fresh;
}

static void
nixWebEnqueue(const NixWebCmd &cmd)
{
	std::lock_guard<std::mutex> lk(gNixWebMutex);
	gNixWebCmds.push_back(cmd);
}

// ---------------------------------------------------------------------------
// HTTP server (single-threaded accept loop; one phone is the whole audience)
// ---------------------------------------------------------------------------

static const char *nixWebPage(void);

static void
nixWebSend(int fd, const char *status, const char *ctype, const char *body, size_t len)
{
	char hdr[256];
	int n = snprintf(hdr, sizeof(hdr),
		"HTTP/1.1 %s\r\n"
		"Content-Type: %s\r\n"
		"Content-Length: %zu\r\n"
		"Cache-Control: no-store\r\n"
		"Connection: close\r\n\r\n",
		status, ctype, len);

	// MSG_NOSIGNAL: a phone dropping the connection mid-write must not
	// SIGPIPE the game.
	if(send(fd, hdr, n, MSG_NOSIGNAL) < 0)
		return;
	size_t off = 0;
	while(off < len){
		ssize_t w = send(fd, body+off, len-off, MSG_NOSIGNAL);
		if(w <= 0)
			return;
		off += w;
	}
}

static void
nixWebSendJson(int fd, const std::string &json)
{
	nixWebSend(fd, "200 OK", "application/json", json.c_str(), json.size());
}

static void
nixWebSendState(int fd)
{
	std::string json;
	if(nixWebAwaitState(json))
		nixWebSendJson(fd, json);
	else{
		const char *body = "{\"ready\":false}";
		nixWebSend(fd, "200 OK", "application/json", body, strlen(body));
	}
}

// Pull `key`'s value out of a "k=v&k=v" body. Values are hex ids, op names
// and numbers, so no percent-decoding is needed.
static bool
nixWebParam(const char *body, const char *key, char *out, size_t outsz)
{
	size_t klen = strlen(key);
	const char *p = body;
	while(p && *p){
		if(strncmp(p, key, klen) == 0 && p[klen] == '='){
			p += klen + 1;
			size_t i = 0;
			while(*p && *p != '&' && i < outsz-1)
				out[i++] = *p++;
			out[i] = '\0';
			return true;
		}
		p = strchr(p, '&');
		if(p) p++;
	}
	return false;
}

static void
nixWebHandleAct(int fd, const char *body)
{
	char idbuf[32], opbuf[16], valbuf[48];
	if(!nixWebParam(body, "id", idbuf, sizeof(idbuf)) ||
	   !nixWebParam(body, "op", opbuf, sizeof(opbuf))){
		const char *err = "{\"ready\":false,\"err\":\"bad request\"}";
		nixWebSend(fd, "400 Bad Request", "application/json", err, strlen(err));
		return;
	}

	NixWebCmd cmd;
	cmd.id = (void*)(uintptr_t)strtoull(idbuf, nil, 16);
	cmd.op = strcmp(opbuf, "trigger") == 0 ? NIXWEB_OP_TRIGGER : NIXWEB_OP_SET;
	cmd.val = nixWebParam(body, "val", valbuf, sizeof(valbuf)) ? atof(valbuf) : 0.0;

	nixWebEnqueue(cmd);
	// Reply with the post-action snapshot so the UI settles in one round trip.
	nixWebSendState(fd);
}

static void
nixWebHandleClient(int fd)
{
	struct timeval tv = { 5, 0 };
	setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
	setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof(tv));

	// Requests are tiny (no uploads); anything that doesn't fit is garbage.
	char req[16384];
	size_t got = 0;
	char *bodyStart = nil;

	while(got < sizeof(req)-1){
		ssize_t r = recv(fd, req+got, sizeof(req)-1-got, 0);
		if(r <= 0)
			return;
		got += r;
		req[got] = '\0';

		char *hdrEnd = strstr(req, "\r\n\r\n");
		if(hdrEnd == nil)
			continue;
		bodyStart = hdrEnd + 4;

		// strcasestr is a GNU extension, so scan for the header by hand.
		size_t want = 0;
		for(const char *p = req; p < hdrEnd; p++)
			if(strncasecmp(p, "content-length:", 15) == 0){
				want = strtoul(p+15, nil, 10);
				break;
			}
		if(got - (bodyStart - req) >= want)
			break;
	}
	if(bodyStart == nil)
		return;

	if(strncmp(req, "GET / ", 6) == 0){
		const char *page = nixWebPage();
		nixWebSend(fd, "200 OK", "text/html; charset=utf-8", page, strlen(page));
	}
	else if(strncmp(req, "GET /api/state", 14) == 0)
		nixWebSendState(fd);
	else if(strncmp(req, "POST /api/act", 13) == 0)
		nixWebHandleAct(fd, bodyStart);
	else
		nixWebSend(fd, "404 Not Found", "text/plain", "not found", 9);
}

static void
nixWebServerLoop(int port)
{
	int s = socket(AF_INET, SOCK_STREAM, 0);
	if(s < 0)
		return;
	int one = 1;
	setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));

	sockaddr_in addr;
	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons((uint16_t)port);
	addr.sin_addr.s_addr = htonl(INADDR_ANY);

	if(bind(s, (sockaddr*)&addr, sizeof(addr)) < 0 || listen(s, 4) < 0){
		fprintf(stderr, "nixweb: cannot listen on port %d: %s\n", port, strerror(errno));
		close(s);
		return;
	}
	printf("nixweb: trainer web UI on http://0.0.0.0:%d\n", port);

	for(;;){
		int c = accept(s, nil, nil);
		if(c < 0){
			if(errno == EINTR)
				continue;
			break;
		}
		nixWebHandleClient(c);
		close(c);
	}
	close(s);
}

// ---------------------------------------------------------------------------
// Game thread: per-frame pump
// ---------------------------------------------------------------------------

// Mirror the overlay's toggles into the debug menu so both in-game UIs and
// the web UI drive the exact same state. Runs after DebugMenuPopulate().
static void
nixWebRegisterTrainer(void)
{
	DebugMenuAddVarBool8("Trainer", "Infinite Health", &gNixInfiniteHealth, nil);
	DebugMenuAddVarBool8("Trainer", "Infinite Car Health", &gNixInfiniteCarHealth, nil);
	DebugMenuAddVarBool8("Trainer", "Infinite Ammo", &gNixInfiniteAmmo, nil);
	DebugMenuAddVarBool8("Trainer", "Never Wanted", &gNixNoWantedLevel, nil);
}

void
NixWebProcess(void)
{
	static bool started = false;
	if(!started){
		started = true;
		nixWebRegisterTrainer();
		int port = NIX_WEB_DEFAULT_PORT;
		const char *env = getenv("REVC_WEB_PORT");
		if(env)
			port = atoi(env);
		if(port > 0)
			std::thread(nixWebServerLoop, port).detach();
	}

	std::vector<NixWebCmd> cmds;
	bool wantState;
	{
		std::lock_guard<std::mutex> lk(gNixWebMutex);
		cmds.swap(gNixWebCmds);
		wantState = gNixWebWantState;
		gNixWebWantState = false;
	}

	// Debug-menu triggers assume a live game world (they spawn cars, teleport
	// the player, ...), so actions are dropped on the frontend; the snapshot
	// carries ingame:false and the UI disables its controls to match.
	bool ingame = FindPlayerPed() != nil;
	if(ingame){
		for(size_t i = 0; i < cmds.size(); i++){
			if(cmds[i].op == NIXWEB_OP_TRIGGER)
				NixDbgTrigger(cmds[i].id);
			else
				NixDbgSet(cmds[i].id, cmds[i].val);
		}
	}

	if(wantState || !cmds.empty()){
		std::string json;
		nixWebBuildState(json, ingame);
		std::lock_guard<std::mutex> lk(gNixWebMutex);
		gNixWebStateJson.swap(json);
		gNixWebStateGen++;
		gNixWebCv.notify_all();
	}
}

// ---------------------------------------------------------------------------
// Embedded phone UI
// ---------------------------------------------------------------------------

static const char *
nixWebPage(void)
{
	static const char page[] = R"NIXWEB(<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="theme-color" content="#121418">
<title>reVC Trainer</title>
<style>
:root{
 --bg:#121418;--card:#1c1f26;--card2:#242833;--line:#2c313c;
 --text:#f0f2f5;--dim:#8c929e;--accent:#5e9cde;--on:#6ed68a;--warn:#d8b95e;--danger:#e07a7a;
}
*{box-sizing:border-box;-webkit-tap-highlight-color:transparent}
body{margin:0;background:var(--bg);color:var(--text);
 font:15px/1.4 system-ui,-apple-system,"Segoe UI",Roboto,sans-serif}
header{position:sticky;top:0;z-index:10;background:rgba(18,20,24,.94);
 backdrop-filter:blur(8px);border-bottom:1px solid var(--line);padding:10px 14px 12px}
.hrow{display:flex;align-items:center;gap:10px}
h1{font-size:17px;margin:0;font-weight:650;letter-spacing:.4px}
h1 b{color:var(--accent)}
#stat{margin-left:auto;color:var(--dim);font-size:12px}
#dot{width:10px;height:10px;border-radius:50%;background:var(--danger);flex:none;transition:background .3s}
#dot.ok{background:var(--on)}
#dot.idle{background:var(--warn)}
#q{width:100%;margin-top:10px;padding:9px 12px;border-radius:10px;border:1px solid var(--line);
 background:var(--card);color:var(--text);font-size:15px;outline:none}
#q:focus{border-color:var(--accent)}
main{padding:4px 10px 40px;max-width:640px;margin:0 auto}
#banner{display:none;margin:10px auto 0;max-width:620px;padding:10px 14px;border-radius:10px;
 background:rgba(216,185,94,.1);border:1px solid rgba(216,185,94,.5);color:#e8d49a;font-size:13px}
body.noact #banner{display:block}
body.noact .ctl{opacity:.4;pointer-events:none}
details{background:var(--card);border:1px solid var(--line);border-radius:12px;margin:10px 0;overflow:hidden}
summary{list-style:none;display:flex;align-items:center;gap:8px;padding:12px 14px;
 font-weight:600;cursor:pointer;user-select:none}
summary::-webkit-details-marker{display:none}
summary .n{margin-left:auto;color:var(--dim);font-size:12px;font-weight:400}
summary:after{content:"\25be";color:var(--dim);transition:transform .15s}
details:not([open]) summary:after{transform:rotate(-90deg)}
.row{display:flex;align-items:center;gap:8px;padding:8px 12px;border-top:1px solid var(--line)}
.row .nm{flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.ctl{flex:none;display:flex;align-items:center}
.star{background:none;border:none;font-size:16px;color:#3a4050;padding:2px 6px 2px 0;cursor:pointer}
.star.on{color:#e8c95e}
button.cmd{background:var(--accent);border:none;color:#0d1117;font-weight:650;
 padding:7px 16px;border-radius:9px;font-size:14px;cursor:pointer}
button.cmd:active{filter:brightness(1.15)}
.sw{position:relative;width:46px;height:26px;display:inline-block}
.sw input{display:none}
.sw i{position:absolute;inset:0;border-radius:13px;background:var(--card2);
 border:1px solid var(--line);transition:.15s}
.sw i:before{content:"";position:absolute;top:2px;left:2px;width:20px;height:20px;
 border-radius:50%;background:var(--dim);transition:.15s}
.sw input:checked+i{background:rgba(110,214,138,.18);border-color:var(--on)}
.sw input:checked+i:before{left:22px;background:var(--on)}
select{background:var(--card2);color:var(--text);border:1px solid var(--line);
 border-radius:8px;padding:6px 8px;font-size:14px;max-width:46vw}
.num{display:flex;align-items:center;gap:4px}
.num button{width:34px;height:34px;border-radius:8px;border:1px solid var(--line);
 background:var(--card2);color:var(--text);font-size:17px;cursor:pointer}
.num input{width:76px;padding:6px 4px;text-align:center;background:var(--card2);
 color:var(--text);border:1px solid var(--line);border-radius:8px;font-size:14px}
.num input:focus{border-color:var(--accent);outline:none}
#toast{position:fixed;left:50%;bottom:24px;transform:translateX(-50%);background:var(--card2);
 border:1px solid var(--line);padding:9px 16px;border-radius:10px;font-size:13px;
 opacity:0;transition:opacity .2s;pointer-events:none;white-space:nowrap;z-index:20}
#toast.show{opacity:1}
.empty{color:var(--dim);text-align:center;padding:40px 10px}
</style>
</head>
<body>
<header>
 <div class="hrow"><h1>reVC <b>TRAINER</b></h1><span id="stat"></span><div id="dot"></div></div>
 <input id="q" type="search" placeholder="Search cheats, spawns, tweaks..." autocomplete="off">
</header>
<div id="banner">Not in a game session yet &mdash; controls unlock once gameplay starts.</div>
<main id="main"><div class="empty">Connecting to reVC&hellip;</div></main>
<div id="toast"></div>
<script>
"use strict";
const $=s=>document.querySelector(s);
let entries=[],byId={},sig="",timer=null,filtering=false;
let favs=new Set(JSON.parse(localStorage.getItem("revcFavs")||"[]"));
let opened=new Set(JSON.parse(localStorage.getItem("revcOpen")||'["Favorites","Trainer","Cheats"]'));
const kfor=e=>e.path+"|"+e.name;
const fmt=v=>Math.abs(v)<1e-9?0:+(+v).toFixed(6);
const isBool=e=>e.choices&&e.choices.length===2&&e.min===0&&e.max===1;

function toast(m){const t=$("#toast");t.textContent=m;t.classList.add("show");
 clearTimeout(t._h);t._h=setTimeout(()=>t.classList.remove("show"),1800)}
function setDot(st){$("#dot").className=st;
 $("#stat").textContent=st==="ok"?"in game":st==="idle"?"waiting for game":"offline"}

async function poll(){
 try{const r=await fetch("/api/state");apply(await r.json())}
 catch(e){setDot("");document.body.classList.add("noact")}
 clearTimeout(timer);timer=setTimeout(poll,2500);
}
function apply(j){
 if(!j||!j.ready){setDot("idle");document.body.classList.add("noact");return}
 setDot(j.ingame?"ok":"idle");
 document.body.classList.toggle("noact",!j.ingame);
 entries=j.entries;byId={};entries.forEach(e=>byId[e.id]=e);
 const s=entries.map(e=>e.id).join();
 if(s!==sig){sig=s;build()}
 refresh();
}
async function act(id,op,val,name){
 try{
  const r=await fetch("/api/act",{method:"POST",body:`id=${id}&op=${op}&val=${val}`});
  const j=await r.json();
  if(j.err)toast(j.err);else if(op==="trigger")toast(name+" ✓");
  apply(j);
 }catch(e){toast("connection lost");setDot("")}
}

function build(){
 const m=$("#main");m.innerHTML="";
 if(!entries.length){m.innerHTML='<div class="empty">No debug-menu entries.</div>';return}
 const groups=new Map();
 entries.forEach(e=>{const p=e.path||"General";
  if(!groups.has(p))groups.set(p,[]);groups.get(p).push(e)});
 const fav=entries.filter(e=>favs.has(kfor(e)));
 if(fav.length)m.appendChild(section("Favorites",fav));
 for(const[p,es]of groups)m.appendChild(section(p,es));
 filter();
}
function section(title,es){
 const d=document.createElement("details");d.dataset.sec=title;
 if(opened.has(title))d.open=true;
 d.addEventListener("toggle",()=>{if(filtering)return;
  d.open?opened.add(title):opened.delete(title);
  localStorage.setItem("revcOpen",JSON.stringify([...opened]))});
 const s=document.createElement("summary");
 const t=document.createElement("span");t.textContent=title.replace(/\|/g," › ");
 const n=document.createElement("span");n.className="n";n.textContent=es.length;
 s.append(t,n);d.appendChild(s);
 es.forEach(e=>d.appendChild(row(e)));
 return d;
}
function row(e){
 const r=document.createElement("div");r.className="row";
 r.dataset.txt=(e.path+" "+e.name).toLowerCase();
 const st=document.createElement("button");
 st.className="star"+(favs.has(kfor(e))?" on":"");st.textContent="★";
 st.onclick=()=>{const k=kfor(e);favs.has(k)?favs.delete(k):favs.add(k);
  localStorage.setItem("revcFavs",JSON.stringify([...favs]));sig="";build()};
 const nm=document.createElement("div");nm.className="nm";nm.textContent=e.name;
 const ct=document.createElement("div");ct.className="ctl";ct.appendChild(control(e));
 r.append(st,nm,ct);return r;
}
function control(e){
 if(e.kind==="cmd"){
  const b=document.createElement("button");b.className="cmd";b.textContent="Run";
  b.onclick=()=>act(e.id,"trigger",0,e.name);return b}
 if(isBool(e)){
  const l=document.createElement("label");l.className="sw";
  const i=document.createElement("input");i.type="checkbox";i.dataset.v=e.id;
  i.checked=e.val>=1;i.onchange=()=>act(e.id,"set",i.checked?1:0,e.name);
  l.append(i,document.createElement("i"));return l}
 if(e.choices){
  const s=document.createElement("select");s.dataset.v=e.id;
  e.choices.forEach((c,ix)=>{const o=document.createElement("option");
   o.value=e.min+ix;o.textContent=c.trim();s.appendChild(o)});
  s.value=e.val;s.onchange=()=>act(e.id,"set",+s.value,e.name);return s}
 const w=document.createElement("div");w.className="num";
 const minus=document.createElement("button");minus.textContent="−";
 const inp=document.createElement("input");inp.type="number";inp.dataset.v=e.id;
 inp.step=e.step||1;inp.value=fmt(e.val);
 const plus=document.createElement("button");plus.textContent="+";
 const bump=d=>{const cur=byId[e.id]?byId[e.id].val:+inp.value;
  let nv=cur+d*(e.step||1);
  if(e.wrap){if(nv>e.max)nv=e.min;if(nv<e.min)nv=e.max}
  else nv=Math.min(e.max,Math.max(e.min,nv));
  act(e.id,"set",fmt(nv),e.name)};
 minus.onclick=()=>bump(-1);plus.onclick=()=>bump(1);
 inp.onchange=()=>act(e.id,"set",+inp.value,e.name);
 w.append(minus,inp,plus);return w;
}
function refresh(){
 document.querySelectorAll("[data-v]").forEach(el=>{
  const e=byId[el.dataset.v];
  if(!e||el===document.activeElement)return;
  if(el.type==="checkbox")el.checked=e.val>=1;
  else el.value=el.tagName==="SELECT"?e.val:fmt(e.val);
 });
}
function filter(){
 const q=$("#q").value.trim().toLowerCase();
 filtering=true;
 document.querySelectorAll("main details").forEach(d=>{
  let vis=0;
  d.querySelectorAll(".row").forEach(r=>{
   const m=!q||r.dataset.txt.includes(q);
   r.style.display=m?"":"none";if(m)vis++});
  d.style.display=vis?"":"none";
  d.open=q?true:opened.has(d.dataset.sec);
 });
 filtering=false;
}
$("#q").addEventListener("input",filter);
document.addEventListener("visibilitychange",()=>{if(!document.hidden)poll()});
poll();
</script>
</body>
</html>
)NIXWEB";
	return page;
}

#else

void NixWebProcess(void) {}

#endif
