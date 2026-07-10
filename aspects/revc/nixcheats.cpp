#include "common.h"
#include "nixcheats.h"

#include "Pad.h"
#include "Font.h"
#include "Sprite2d.h"
#include "Rect.h"

#include "World.h"
#include "PlayerInfo.h"
#include "PlayerPed.h"
#include "Ped.h"
#include "Wanted.h"
#include "Weapon.h"
#include "WeaponType.h"
#include "Vehicle.h"

// Large enough to never run dry in a normal play session, well within int32.
#define NIX_INFINITE_AMMO 99999
// Vice City vehicles treat 1000.0f as full health.
#define NIX_VEHICLE_FULL_HEALTH 1000.0f

bool gNixInfiniteHealth = false;
bool gNixInfiniteCarHealth = false;
bool gNixInfiniteAmmo = false;
bool gNixNoWantedLevel = false;

bool gNixTrainerOpen = false;
int gNixTrainerSel = 0;

// Toggle table: keep the pointers, labels, and count in lockstep.
static bool *const gNixToggles[] = {
	&gNixInfiniteHealth,
	&gNixInfiniteCarHealth,
	&gNixInfiniteAmmo,
	&gNixNoWantedLevel,
};
static const char *const gNixLabels[] = {
	"Infinite Health",
	"Infinite Car Health",
	"Infinite Ammo",
	"Never Wanted",
};
#define NIX_TOGGLE_COUNT ((int)ARRAY_SIZE(gNixToggles))

// ---------------------------------------------------------------------------
// Cheat enforcement
// ---------------------------------------------------------------------------

void
NixCheatsProcess(void)
{
	CPlayerPed *player = FindPlayerPed();
	if (player == nil)
		return;

	if (gNixInfiniteHealth)
		player->m_fHealth = (float)CWorld::Players[0].m_nMaxHealth;

	if (gNixInfiniteCarHealth) {
		CVehicle *veh = FindPlayerVehicle();
		if (veh != nil)
			veh->m_fHealth = NIX_VEHICLE_FULL_HEALTH;
	}

	if (gNixInfiniteAmmo) {
		for (int slot = 0; slot < TOTAL_WEAPON_SLOTS; slot++) {
			CWeapon &weapon = player->GetWeapon(slot);
			if (weapon.m_eWeaponType != WEAPONTYPE_UNARMED)
				weapon.m_nAmmoTotal = NIX_INFINITE_AMMO;
		}
	}

	// Keep the wanted level pinned at zero so it can never climb.
	if (gNixNoWantedLevel && player->m_pWanted != nil) {
		if (player->m_pWanted->GetWantedLevel() != 0)
			player->m_pWanted->CheatWantedLevel(0);
	}
}

// ---------------------------------------------------------------------------
// Input (Ctrl+T to toggle; vim keys to navigate)
// ---------------------------------------------------------------------------

void
NixTrainerInput(void)
{
	CPad *pad = CPad::GetPad(0);

	// Ctrl+T opens/closes the panel from anywhere.
	if ((pad->GetLeftCtrl() || pad->GetRightCtrl()) && pad->GetCharJustDown('T')) {
		gNixTrainerOpen = !gNixTrainerOpen;
		return;
	}

	if (!gNixTrainerOpen)
		return;

	// j / k : move down / up (wrapping).
	if (pad->GetCharJustDown('J'))
		gNixTrainerSel = (gNixTrainerSel + 1) % NIX_TOGGLE_COUNT;
	if (pad->GetCharJustDown('K'))
		gNixTrainerSel = (gNixTrainerSel + NIX_TOGGLE_COUNT - 1) % NIX_TOGGLE_COUNT;
	// g / G : jump to top / bottom.
	if (pad->GetCharJustDown('G'))
		gNixTrainerSel = (pad->GetLeftShift() || pad->GetRightShift()) ? NIX_TOGGLE_COUNT - 1 : 0;

	// l / h / Enter / Space : flip the selected toggle.
	if (pad->GetCharJustDown('L') || pad->GetCharJustDown('H') ||
	    pad->GetEnterJustDown() || pad->GetCharJustDown(' '))
		*gNixToggles[gNixTrainerSel] = !*gNixToggles[gNixTrainerSel];

	// q / Esc : close.
	if (pad->GetCharJustDown('Q') || pad->GetEscapeJustDown())
		gNixTrainerOpen = false;
}

// ---------------------------------------------------------------------------
// Rendering (overlay panel)
// ---------------------------------------------------------------------------

// Layout, in PS2 (640x448) design space; stretched to the real resolution.
#define TRN_X(a) SCREEN_STRETCH_X((float)(a))
#define TRN_Y(a) SCREEN_STRETCH_Y((float)(a))

#define TRN_PANEL_X 34.0f
#define TRN_PANEL_Y 82.0f
#define TRN_PANEL_W 256.0f
#define TRN_TITLE_H 30.0f
#define TRN_ROW_H 27.0f
#define TRN_PAD 9.0f

// Neutral dark palette with a single muted blue accent.
static const CRGBA TRN_ACCENT(94, 156, 222, 255);
static const CRGBA TRN_ACCENT_DIM(94, 156, 222, 170);
static const CRGBA TRN_TITLE_BG(40, 44, 52, 245);
static const CRGBA TRN_BG_TOP(28, 30, 36, 235);
static const CRGBA TRN_BG_BOTTOM(18, 20, 24, 235);
static const CRGBA TRN_HIGHLIGHT(94, 156, 222, 60);
static const CRGBA TRN_ON(110, 214, 138, 255);
static const CRGBA TRN_GREY(140, 144, 152, 255);
static const CRGBA TRN_WHITE(240, 242, 245, 255);
static const CRGBA TRN_LABEL(200, 204, 210, 255);

static void
NixTrainerText(float x, float y, float scale, int16 style, CRGBA col, const char *str)
{
	wchar buf[64];
	AsciiToUnicode(str, buf);

	CFont::SetFontStyle(style);
	CFont::SetScale(SCREEN_SCALE_X(scale), SCREEN_SCALE_Y(scale));
	CFont::SetPropOn();
	CFont::SetJustifyOff();
	CFont::SetRightJustifyOff();
	CFont::SetCentreOff();
	CFont::SetBackgroundOff();
	CFont::SetWrapx(SCREEN_STRETCH_X(640.0f));
	CFont::SetDropShadowPosition(1);
	CFont::SetDropColor(CRGBA(0, 0, 0, 220));
	CFont::SetColor(col);
	CFont::PrintString(TRN_X(x), TRN_Y(y), buf);
}

void
NixTrainerRender(void)
{
	if (!gNixTrainerOpen)
		return;

	float x0 = TRN_PANEL_X;
	float y0 = TRN_PANEL_Y;
	float x1 = x0 + TRN_PANEL_W;
	float bodyTop = y0 + TRN_TITLE_H;
	float bodyH = TRN_PAD * 2.0f + NIX_TOGGLE_COUNT * TRN_ROW_H;
	float y1 = bodyTop + bodyH;

	// Body: subtle vertical gradient over a dark slate.
	CSprite2d::DrawRect(CRect(TRN_X(x0), TRN_Y(bodyTop), TRN_X(x1), TRN_Y(y1)),
	    TRN_BG_TOP, TRN_BG_TOP, TRN_BG_BOTTOM, TRN_BG_BOTTOM);
	// Title bar: flat, slightly lighter than the body.
	CSprite2d::DrawRect(CRect(TRN_X(x0), TRN_Y(y0), TRN_X(x1), TRN_Y(bodyTop)), TRN_TITLE_BG);
	// Thin accent line separating the title bar from the body.
	CSprite2d::DrawRect(
	    CRect(TRN_X(x0), TRN_Y(bodyTop - 1.5f), TRN_X(x1), TRN_Y(bodyTop)), TRN_ACCENT);
	// Left accent stripe.
	CSprite2d::DrawRect(CRect(TRN_X(x0), TRN_Y(bodyTop), TRN_X(x0 + 3.0f), TRN_Y(y1)), TRN_ACCENT);

	NixTrainerText(x0 + 12.0f, y0 + 6.0f, 0.55f, FONT_BANK, TRN_WHITE, "TRAINER");

	for (int i = 0; i < NIX_TOGGLE_COUNT; i++) {
		float ry = bodyTop + TRN_PAD + i * TRN_ROW_H;

		if (i == gNixTrainerSel)
			CSprite2d::DrawRect(
			    CRect(TRN_X(x0 + 3.0f), TRN_Y(ry - 2.0f), TRN_X(x1), TRN_Y(ry + TRN_ROW_H - 5.0f)),
			    TRN_HIGHLIGHT);

		NixTrainerText(x0 + 14.0f, ry, 0.5f, FONT_BANK,
		    i == gNixTrainerSel ? TRN_WHITE : TRN_LABEL, gNixLabels[i]);

		bool on = *gNixToggles[i];
		NixTrainerText(x1 - 44.0f, ry, 0.5f, FONT_BANK, on ? TRN_ON : TRN_GREY, on ? "ON" : "OFF");
	}

	NixTrainerText(x0, y1 + 5.0f, 0.38f, FONT_BANK, TRN_ACCENT_DIM,
	    "j/k move   l toggle   q close   ctrl+t");
}
