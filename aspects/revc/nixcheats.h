#pragma once

// Persistent "trainer" for reVC, layered on by the Nix build.
//
// Three pieces, all self-contained in nixcheats.cpp and wired into the engine
// with a few one-line hooks from the Nix derivation:
//   * sticky cheat toggles, enforced every frame (NixCheatsProcess)
//   * a vim-navigable overlay panel (NixTrainerRender)
//   * input handling for the panel (NixTrainerInput)
//
// Adding another cheat: declare a bool below, enforce it in NixCheatsProcess,
// and add it to the gNixToggles/gNixLabels tables in nixcheats.cpp.

// Cheat toggles.
extern bool gNixInfiniteHealth;
extern bool gNixInfiniteCarHealth;
extern bool gNixInfiniteAmmo;
extern bool gNixNoWantedLevel;

// Overlay UI state.
extern bool gNixTrainerOpen;
extern int gNixTrainerSel;

// Enforce the enabled toggles for this frame. No-op with no player ped yet, so
// it is safe to call unconditionally. Call once per frame.
void NixCheatsProcess(void);

// Poll input: Ctrl+T opens/closes the panel; while open, vim keys navigate it.
// Call once per frame, after the pad state has been updated.
void NixTrainerInput(void);

// Draw the overlay panel. No-op while the panel is closed. Must be called from
// the 2D render pass, before CFont::DrawFonts() flushes the text buffer.
void NixTrainerRender(void);
