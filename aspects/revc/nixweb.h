#pragma once

// Remote-control web server for the reVC trainer + debug menu, layered on by
// the Nix build. Split across three pieces:
//
//   * nixweb.cpp        — HTTP server thread, per-frame pump (NixWebProcess),
//                         and the embedded phone UI.
//   * nixweb_bridge.cpp — appended to the end of debugmenu.cpp by the Nix
//                         derivation, because the Menu/MenuEntry class
//                         definitions it reflects over are private to that
//                         file. Implements the NixDbg* functions below.
//   * this header       — the contract between the two.
//
// Threading model: the HTTP thread never touches game state. It only enqueues
// actions and waits for state snapshots; NixWebProcess(), called once per
// frame on the game thread, drains the queue and serializes the snapshot. The
// NixDbg* functions must therefore only ever be called from the game thread.

// Entry kinds reported by the bridge.
enum NixDbgKind {
	NIXDBG_INT = 0,
	NIXDBG_FLOAT = 1,
	NIXDBG_CMD = 2,
};

// One debug-menu entry, flattened. `path` is the submenu chain joined with
// '|' (e.g. "Debug|Particle"); `strings` (when non-null) holds the display
// labels for the values lower..upper, i.e. choice index = value - lower.
// The string pointers are only valid for the duration of the walk callback.
struct NixDbgEntryInfo {
	void *id; // opaque handle (the MenuEntry*), stable for the session
	const char *path;
	const char *name;
	int kind;
	double value, lower, upper, step;
	bool wrap;
	const char **strings;
	int nstrings;
};

typedef void (*NixDbgWalkCb)(const NixDbgEntryInfo *info, void *user);

// Depth-first walk over every value/command entry of the debug menu, in
// registration order (the same order the in-game menu shows).
void NixDbgWalk(NixDbgWalkCb cb, void *user);

// Set a numeric entry to `value` (clamped to its bounds) and fire its trigger
// callback on change. Returns false if `id` is not a live numeric entry.
bool NixDbgSet(void *id, double value);

// Run a command entry's trigger. Returns false if `id` is not a live command.
bool NixDbgTrigger(void *id);

// Per-frame pump: starts the server on first call, applies queued actions,
// and publishes state snapshots. Call once per frame on the game thread.
void NixWebProcess(void);
