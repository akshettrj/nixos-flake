
// ---------------------------------------------------------------------------
// Appended to the end of debugmenu.cpp by the Nix derivation (see nixweb.h).
//
// The web trainer needs to enumerate and mutate debug-menu entries, but the
// concrete Menu / MenuEntry_* class definitions live only in this translation
// unit — so the reflection helpers are grafted on here, where they can reuse
// the INTTYPES / FLOATTYPES X-macro lists to cover every entry type without
// duplicating any layout knowledge. Game-thread only; see nixweb.h.
// ---------------------------------------------------------------------------

#ifdef DEBUGMENU

#include "nixweb.h"

static void
nixDbgDescribe(MenuEntry_Var *v, NixDbgEntryInfo *info)
{
	info->kind = NIXDBG_CMD;
	info->value = info->lower = info->upper = info->step = 0.0;
	info->wrap = v->wrapAround;
	info->strings = nil;
	info->nstrings = 0;

#define X(NAME, TYPE, MAXLEN, FMT) \
	if(MenuEntry_##NAME *e = dynamic_cast<MenuEntry_##NAME*>(v)){ \
		info->kind = NIXDBG_INT; \
		info->value = (double)*e->variable; \
		info->lower = (double)e->lowerBound; \
		info->upper = (double)e->upperBound; \
		info->step = (double)e->step; \
		info->strings = e->strings; \
		if(e->strings) \
			info->nstrings = (int)(e->upperBound - e->lowerBound) + 1; \
		return; \
	}
	INTTYPES
#undef X

#define X(NAME, TYPE, MAXLEN, FMT) \
	if(MenuEntry_##NAME *e = dynamic_cast<MenuEntry_##NAME*>(v)){ \
		info->kind = NIXDBG_FLOAT; \
		info->value = (double)*e->variable; \
		info->lower = (double)e->lowerBound; \
		info->upper = (double)e->upperBound; \
		info->step = (double)e->step; \
		return; \
	}
	FLOATTYPES
#undef X
}

static void
nixDbgWalkMenu(Menu *m, char *path, int pathlen, int pathmax, NixDbgWalkCb cb, void *user)
{
	MenuEntry *e;
	for(e = m->entries; e; e = e->next){
		if(e->type == MENUSUB){
			int n = snprintf(path+pathlen, pathmax-pathlen,
				pathlen == 0 ? "%s" : "|%s", e->name);
			if(n > 0 && pathlen+n < pathmax)
				nixDbgWalkMenu(((MenuEntry_Sub*)e)->submenu,
					path, pathlen+n, pathmax, cb, user);
			path[pathlen] = '\0';
		}else if(e->type == MENUVAR){
			NixDbgEntryInfo info;
			info.id = e;
			info.path = path;
			info.name = e->name;
			nixDbgDescribe((MenuEntry_Var*)e, &info);
			cb(&info, user);
		}
	}
}

void
NixDbgWalk(NixDbgWalkCb cb, void *user)
{
	char path[512];
	path[0] = '\0';
	nixDbgWalkMenu(&toplevel, path, 0, sizeof(path), cb, user);
}

// Untrusted handles come in over HTTP, so resolve them against the live tree
// instead of dereferencing them blindly.
static MenuEntry*
nixDbgFind(Menu *m, void *id)
{
	MenuEntry *e;
	for(e = m->entries; e; e = e->next){
		if((void*)e == id && e->type == MENUVAR)
			return e;
		if(e->type == MENUSUB){
			MenuEntry *found = nixDbgFind(((MenuEntry_Sub*)e)->submenu, id);
			if(found)
				return found;
		}
	}
	return nil;
}

bool
NixDbgSet(void *id, double value)
{
	MenuEntry *e = nixDbgFind(&toplevel, id);
	if(e == nil)
		return false;
	MenuEntry_Var *v = (MenuEntry_Var*)e;

#define X(NAME, TYPE, MAXLEN, FMT) \
	if(MenuEntry_##NAME *t = dynamic_cast<MenuEntry_##NAME*>(v)){ \
		TYPE nv = (TYPE)value; \
		if(nv < t->lowerBound) nv = t->lowerBound; \
		if(nv > t->upperBound) nv = t->upperBound; \
		if(*t->variable != nv){ \
			*t->variable = nv; \
			if(t->triggerFunc) \
				t->triggerFunc(); \
		} \
		return true; \
	}
	INTTYPES
	FLOATTYPES
#undef X

	return false;
}

bool
NixDbgTrigger(void *id)
{
	MenuEntry *e = nixDbgFind(&toplevel, id);
	if(e == nil)
		return false;
	MenuEntry_Cmd *c = dynamic_cast<MenuEntry_Cmd*>((MenuEntry_Var*)e);
	if(c == nil || c->triggerFunc == nil)
		return false;
	c->triggerFunc();
	return true;
}

#endif
