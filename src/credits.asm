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
    ;; Load the tileset and colorset.
    ld b, TILESET_PUZZ_SPACE  ; param: tileset
    call Func_LoadTileset
    ld c, COLORSET_SPACE  ; param: colorset
    call FuncX_Colorset_Load
_CreditsScreen_LoadTileMap:
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
_CreditsScreen_LoadColor:
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
_CreditsScreen_SetUpScreen:
    ;; Set up screen parameters and fade in.
    PLAY_SONG DataX_TitleMusic_song
    call Func_ClearOam
    xor a
    ldh [rSCX], a
    ldh [rSCY], a
    ld d, LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16
    call Func_FadeIn
_CreditsScreen_Dialog:
    ;; Play dialog.
    ld hl, Data_Credits1_dlog_bptr
    call Func_RunDialog
    ld hl, Data_Credits2_dlog_bptr
    call Func_RunDialog
_CreditsScreen_Finish:
    ;; Fade out and return to title screen.
    call Func_FadeOut
    jp Main_TitleScreen

Data_Credits1_dlog_bptr:
    D_BPTR DataX_Credits1_dlog
Data_Credits2_dlog_bptr:
    D_BPTR DataX_Credits2_dlog

;;;=========================================================================;;;
