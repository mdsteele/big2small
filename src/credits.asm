;;;=========================================================================;;;
;;; Copyright 2020 Matthew D. Steele <mdsteele@alum.mit.edu>                ;;;
;;;                                                                         ;;;
;;; This file is part of Big2Small.                                         ;;;
;;;                                                                         ;;;
;;; Big2Small is free software: you can redistribute it and/or modify it    ;;;
;;; under the terms of the GNU General Public License as published by the   ;;;
;;; Free Software Foundation, either version 3 of the License, or (at your  ;;;
;;; option) any later version.                                              ;;;
;;;                                                                         ;;;
;;; Big2Small is distributed in the hope that it will be useful, but        ;;;
;;; WITHOUT ANY WARRANTY; without even the implied warranty of              ;;;
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU       ;;;
;;; General Public License for more details.                                ;;;
;;;                                                                         ;;;
;;; You should have received a copy of the GNU General Public License along ;;;
;;; with Big2Small.  If not, see <http://www.gnu.org/licenses/>.            ;;;
;;;=========================================================================;;;

INCLUDE "src/color.inc"
INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"
INCLUDE "src/tileset.inc"
INCLUDE "src/vram.inc"

;;;=========================================================================;;;

SHIP_PALETTE   EQU (OAMF_PAL1 | 5)
THRUST_PALETTE EQU (OAMF_PAL1 | 6)

MINI_SHIP_1_TILEID EQU $78
SHIP_L_TILEID      EQU $b2
SHIP_M_TILEID      EQU $b4
SHIP_R_TILEID      EQU $b6
SOLID_BLACK_TILEID EQU $fb
THRUST_1_TILEID    EQU $b8

SHIP_TOP EQU 65

D_BPTR: MACRO
    STATIC_ASSERT _NARG == 1
    DB BANK(\1), LOW(\1), HIGH(\1)
ENDM

;;;=========================================================================;;;

SECTION "CreditsState", WRAM0

Ram_CreditsAnimationCounter_u8:
    DB

;;;=========================================================================;;;

SECTION "CreditsFunctions", ROM0

;;; @prereq LCD is off.
Main_CreditsScreen::
    xor a
    ld [Ram_AnimationClock_u8], a
    ldh [rSCX], a
    ldh [rSCY], a
    ld c, COLORSET_MOON  ; param: colorset
    xcall FuncX_Colorset_Load
_CreditsScreen_Flying:
    call Func_CreditsLoadFlyingScreen
    PLAY_SONG DataX_Title_song
    ld d, LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16
    call Func_FadeIn
    ld a, GRAYSCALE_PALETTE_23
    ldh [rOBP1], a
    ld hl, Data_CreditsFlying_dlog_bptr  ; param: dialog
    ld de, Func_CreditsFlyingAnimate  ; param: update func
    call Func_RunDialog
    call Func_FadeOut
_CreditsScreen_Moon1:
    call Func_CreditsLoadMoonScreen
    ld d, LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ8
    call Func_FadeIn
    ld a, GRAYSCALE_PALETTE_23
    ldh [rOBP1], a
    ld hl, Data_CreditsMoon1_dlog_bptr  ; param: dialog
    ld de, Func_CreditsMoonAnimate  ; param: update func
    call Func_RunDialog
    ld c, 60
_CreditsScreen_Wait:
    push bc
    call Func_CreditsMoonAnimate
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_AnimateTiles
    pop bc
    dec c
    jr nz, _CreditsScreen_Wait
_CreditsScreen_Moon2:
    ld hl, Data_CreditsMoon2_dlog_bptr  ; param: dialog
    ld de, Func_CreditsMoonAnimate  ; param: update func
    call Func_RunDialog
    call Func_FadeOut
_CreditsScreen_Finish:
    jp Main_TitleScreen

Data_CreditsFlying_dlog_bptr:
    D_BPTR DataX_CreditsFlying_dlog
Data_CreditsMoon1_dlog_bptr:
    D_BPTR DataX_CreditsMoon1_dlog
Data_CreditsMoon2_dlog_bptr:
    D_BPTR DataX_CreditsMoon2_dlog

;;;=========================================================================;;;

;;; @prereq LCD is off.
Func_CreditsLoadFlyingScreen:
    ld b, TILESET_PUZZ_SPACE  ; param: tileset
    call Func_LoadTileset
_CreditsLoadFlyingScreen_LoadTileMap:
    ;; Fill the relevant part of the background map with animated tiles.
    ld a, ANIMATED_TILEID
    ld hl, Vram_BgMap
    ld c, 141
    .clearLoop
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    dec c
    jr nz, .clearLoop
_CreditsLoadFlyingScreen_LoadColor:
    ;; If color is enabled, load color data into VRAM.
    if_dmg jr, .noColor
    ld a, 1
    ldh [rVBK], a
    ld a, 4
    ld hl, Vram_BgMap
    ld c, 141
    .colorLoop
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    dec c
    jr nz, .colorLoop
    xor a
    ldh [rVBK], a
    .noColor
_CreditsLoadFlyingScreen_SetUpOjbects:
    call Func_ClearOam
    ld a, SHIP_TOP
    ld [Ram_Thrust_oama + OAMA_Y], a
    ld [Ram_ShipL_oama + OAMA_Y], a
    ld [Ram_ShipM_oama + OAMA_Y], a
    ld [Ram_ShipR_oama + OAMA_Y], a
    ld a, 8 + SCRN_X / 2 - 15
    ld [Ram_Thrust_oama + OAMA_X], a
    add 5
    ld [Ram_ShipL_oama + OAMA_X], a
    add 8
    ld [Ram_ShipM_oama + OAMA_X], a
    add 8
    ld [Ram_ShipR_oama + OAMA_X], a
    ld a, THRUST_PALETTE
    ld [Ram_Thrust_oama + OAMA_FLAGS], a
    ld a, SHIP_PALETTE
    ld [Ram_ShipL_oama + OAMA_FLAGS], a
    ld [Ram_ShipM_oama + OAMA_FLAGS], a
    ld [Ram_ShipR_oama + OAMA_FLAGS], a
    ld a, THRUST_1_TILEID
    ld [Ram_Thrust_oama + OAMA_TILEID], a
    ld a, SHIP_L_TILEID
    ld [Ram_ShipL_oama + OAMA_TILEID], a
    ld a, SHIP_M_TILEID
    ld [Ram_ShipM_oama + OAMA_TILEID], a
    ld a, SHIP_R_TILEID
    ld [Ram_ShipR_oama + OAMA_TILEID], a
    ret

Func_CreditsFlyingAnimate:
    ;; Animate the ship's thrust.
    ld a, [Ram_AnimationClock_u8]
    ld c, a
    and %00000100
    rrca
    ld b, a
    ld a, [Ram_Thrust_oama + OAMA_TILEID]
    and %11111100
    or b
    ld [Ram_Thrust_oama + OAMA_TILEID], a
    ;; Move the ship up and down.
    ld a, c
    and %00110000
    swap a
    if_ne 3, jr, .move
    ld a, 1
    .move
    add SHIP_TOP
    ld [Ram_Thrust_oama + OAMA_Y], a
    ld [Ram_ShipL_oama + OAMA_Y], a
    ld [Ram_ShipM_oama + OAMA_Y], a
    ld [Ram_ShipR_oama + OAMA_Y], a
    ret

;;;=========================================================================;;;

;;; @prereq LCD is off.
Func_CreditsLoadMoonScreen:
    ld b, TILESET_MAP_SPACE  ; param: tileset
    call Func_LoadTileset
_CreditsLoadMoonScreen_LoadTileMap:
    xld de, DataX_MoonTileMap_start
    ld hl, Vram_BgMap + SCRN_VY_B
    ld b, SCRN_Y_B - 2
    .rowLoop
    ld c, SCRN_X_B
    .colLoop
    ld a, [de]
    inc de
    ld [hl+], a
    dec c
    jr nz, .colLoop
    ld a, b
    ld bc, SCRN_VX_B - SCRN_X_B
    add hl, bc
    ld b, a
    dec b
    jr nz, .rowLoop
    ;; Fill in black for the top and bottom rows.
    ld a, SOLID_BLACK_TILEID
    ld hl, Vram_BgMap
    ld c, SCRN_X_B
    .topRowLoop
    ld [hl+], a
    dec c
    jr nz, .topRowLoop
    ld hl, Vram_BgMap + SCRN_VX_B * (SCRN_Y_B - 1)
    ld c, SCRN_X_B
    .botRowLoop
    ld [hl+], a
    dec c
    jr nz, .botRowLoop
_CreditsLoadMoonScreen_LoadColor:
    ;; If color is enabled, load color data into VRAM.
    if_dmg jr, .noColor
    xld de, DataX_MoonTileMap_start  ; param: BG tile map pointer
    ld b, 4  ; param: top/bottom row palette
    call Func_LoadAreaMapColor
    .noColor
_CreditsLoadMoonScreen_SetUpOjbects:
    xor a
    ld [Ram_CreditsAnimationCounter_u8], a
    call Func_ClearOam
    ld a, SHIP_PALETTE
    ld [Ram_ShipM_oama + OAMA_FLAGS], a
    ret

MOON_SHIP_DELAY EQU 20
MOON_SHIP_STEPS EQU 200

Func_CreditsMoonAnimate:
    ;; If we've reached the end of the CreditsMoonShipPositions table, no
    ;; further updates are needed.
    ld a, [Ram_CreditsAnimationCounter_u8]
    if_ge MOON_SHIP_DELAY + MOON_SHIP_STEPS, ret
    ;; Increment Ram_CreditsAnimationCounter_u8, keeping the old value in a.
    inc a
    ld [Ram_CreditsAnimationCounter_u8], a
    dec a
    ;; Do nothing for the first MOON_SHIP_DELAY frames.
    if_lt MOON_SHIP_DELAY, ret
    sub MOON_SHIP_DELAY
    jr nz, .doneSound
    PLAY_SFX4 DataX_LaunchShip_sfx4
    .doneSound
    ;; Update the object tile ID.
_CreditsMoonAnimate_Tile:
    ld b, MINI_SHIP_1_TILEID
    if_lt MOON_SHIP_STEPS * 1 / 4, jr, .setTile
    inc b
    if_lt MOON_SHIP_STEPS * 2 / 4, jr, .setTile
    inc b
    if_lt MOON_SHIP_STEPS * 3 / 4, jr, .setTile
    inc b
    if_lt MOON_SHIP_STEPS - 1, jr, .setTile
    inc b
    .setTile
    ld hl, Ram_ShipM_oama + OAMA_TILEID
    ld [hl], b
_CreditsMoonAnimate_Position:
    ;; At this point, a ranges from 0 to (MOON_SHIP_STEPS - 1).  Store 2*a in
    ;; bc (accounting for a carry bit, since 2 * (MOON_SHIP_STEPS - 1) doesn't
    ;; fit in one byte).
    ASSERT 2 * (MOON_SHIP_STEPS - 1) >= $100
    ASSERT 2 * (MOON_SHIP_STEPS - 1) < $200
    add a
    ld c, a
    ld a, 0
    rla
    ld b, a
    ;; Make hl point to the (x, y) pair to use.
    ld hl, Data_CreditsMoonShipPositions_u8_pair_arr
    add hl, bc
    ;; Update the object's (x, y) position from the table entry.
    ld a, [hl+]
    ld [Ram_ShipM_oama + OAMA_X], a
    ld a, [hl]
    ld [Ram_ShipM_oama + OAMA_Y], a
    ret

;;; Control points for the cubic bezier curve that defines the ship's path.
MOON_SHIP_CTRL0_X EQU 0.0
MOON_SHIP_CTRL0_Y EQU 108.0
MOON_SHIP_CTRL1_X EQU 20.0
MOON_SHIP_CTRL1_Y EQU 113.0
MOON_SHIP_CTRL2_X EQU 170.0
MOON_SHIP_CTRL2_Y EQU 43.0
MOON_SHIP_CTRL3_X EQU 104.0
MOON_SHIP_CTRL3_Y EQU 56.0

Data_CreditsMoonShipPositions_u8_pair_arr:
    .begin
    ;; Populate the table with a cubic bezier curve, using the above control
    ;; points.  N is the integer loop variable that ranges from 0 to
    ;; MOON_SHIP_STEPS - 1.
N = 0
    REPT MOON_SHIP_STEPS
    ;; P is a fixed-point parameter that varies linearly from 0.0 to 1.0 (note
    ;; that rgbasm uses (foo << 16) to convert from integer to fixed-point).
P = DIV(N << 16, (MOON_SHIP_STEPS - 1) << 16)
    ;; T is the fixed-point bezier curve parameter, ranging from 0.0 to 1.0.
    ;; It is dervied from P non-linearly, increasing quickly at first and then
    ;; slowing down.  The ATAN function is the most convenient way to get the
    ;; shape we want from rgbasm, but rgbasm's trig functions represent a
    ;; full-turn angle as 65536.0 rather than 6.28 or 360.0, which we why we
    ;; have to divide by such a big number to normalize to [0.0, 1.0].
T = DIV(ATAN(MUL(P, 5.0)), 14325.0)
    ;; For convenience, we also calculate T^2, (1-T), and (1-T)^2.
T2 = MUL(T, T)
S = (1.0 - T)
S2 = MUL(S, S)
    ;; Emit the X and Y values for this table entry.
C_0 = MUL(S2, S)
C_1 = MUL(3.0, MUL(S2, T))
C_2 = MUL(3.0, MUL(S, T2))
C_3 = MUL(T2, T)
    DB (MUL(MOON_SHIP_CTRL0_X, C_0) \
        + MUL(MOON_SHIP_CTRL1_X, C_1) \
        + MUL(MOON_SHIP_CTRL2_X, C_2) \
        + MUL(MOON_SHIP_CTRL3_X, C_3)) >> 16
    DB (MUL(MOON_SHIP_CTRL0_Y, C_0) \
        + MUL(MOON_SHIP_CTRL1_Y, C_1) \
        + MUL(MOON_SHIP_CTRL2_Y, C_2) \
        + MUL(MOON_SHIP_CTRL3_Y, C_3)) >> 16
N = (N + 1)
    ENDR
    ASSERT @ - .begin == 2 * MOON_SHIP_STEPS

;;;=========================================================================;;;
