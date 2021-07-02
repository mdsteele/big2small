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

;;;=========================================================================;;;

SOLID_BLACK_TILE_ID EQU $fb

D_BPTR: MACRO
    STATIC_ASSERT _NARG == 1
    DB BANK(\1), LOW(\1), HIGH(\1)
ENDM

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
    PLAY_SONG DataX_TitleMusic_song
    ld d, LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16
    call Func_FadeIn
    ld hl, Data_Credits1_dlog_bptr
    call Func_RunDialog
    call Func_FadeOut
_CreditsScreen_Moon:
    call Func_CreditsLoadMoonScreen
    ld d, LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16
    call Func_FadeIn
    ld hl, Data_Credits2_dlog_bptr
    call Func_RunDialog
    call Func_FadeOut
_CreditsScreen_Finish:
    jp Main_TitleScreen

Data_Credits1_dlog_bptr:
    D_BPTR DataX_Credits1_dlog
Data_Credits2_dlog_bptr:
    D_BPTR DataX_Credits2_dlog

;;;=========================================================================;;;

;;; @prereq LCD is off.
Func_CreditsLoadFlyingScreen:
    ld b, TILESET_PUZZ_SPACE  ; param: tileset
    call Func_LoadTileset
_CreditsLoadFlyingScreen_LoadTileMap:
    ;; Fill the relevant part of the background map with animated tiles.
    ld a, ANIMATED_TILE_ID
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
    ldh a, [Hram_ColorEnabled_bool]
    or a
    jr z, .noColor
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
    ;; TODO: Set up spaceship objects.
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
    ld a, SOLID_BLACK_TILE_ID
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
    ldh a, [Hram_ColorEnabled_bool]
    or a
    jr z, .noColor
    xld de, DataX_MoonTileMap_start
    call Func_LoadAreaMapColor
    .noColor
_CreditsLoadMoonScreen_SetUpOjbects:
    call Func_ClearOam
    ret

;;;=========================================================================;;;
