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

INCLUDE "src/hardware.inc"
INCLUDE "src/vram.inc"

;;;=========================================================================;;;

;;; Store the stack at the back of WRAM.
SECTION "Stack", WRAM0[$DF00]
    DS $100
Ram_BottomOfStack:

;;;=========================================================================;;;

SECTION "Main", ROM0[$0150]
Main::
    ld sp, Ram_BottomOfStack
    call Func_InitDmaCode
    ;; Enable VBlank interrupt.
    ld a, IEF_VBLANK
    ldh [rIE], a
    ei
    ;; Turn off the LCD.
    call Func_WaitForVBlank
    ld a, LCDCF_OFF
    ld [rLCDC], a
    ;; Copy tiles to VRAM.
    ld hl, Vram_BgTiles + 0 * sizeof_TILE                 ; dest
    ld de, Data_DeviceTiles_start                         ; src
    ld bc, Data_DeviceTiles_end - Data_DeviceTiles_start  ; count
    call Func_MemCopy
    ld hl, Vram_BgTiles + "!" * sizeof_TILE           ; dest
    ld de, Data_FontTiles_start                       ; src
    ld bc, Data_FontTiles_end - Data_FontTiles_start  ; count
    call Func_MemCopy
    ld hl, Vram_SharedTiles + 0 * sizeof_TILE               ; dest
    ld de, Data_TerrainTiles_start                          ; src
    ld bc, Data_TerrainTiles_end - Data_TerrainTiles_start  ; count
    call Func_MemCopy
    ld hl, Vram_ObjTiles                            ; dest
    ld de, Data_ObjTiles_start                      ; src
    ld bc, Data_ObjTiles_end - Data_ObjTiles_start  ; count
    call Func_MemCopy
    ;; Initialize palettes.
    ld a, %11100100
    ldh [rBGP], a
    ldh [rOBP0], a
    ldh [rOBP1], a
    ;; Copy strings to background map.
    ld hl, Vram_BgMap + 6 + 13 * SCRN_VX_B        ; dest
    ld de, Data_String1_start                     ; src
    ld bc, Data_String1_end - Data_String1_start  ; count
    call Func_MemCopy
    ld hl, Vram_BgMap + 6 + 15 * SCRN_VX_B        ; dest
    ld de, Data_String2_start                     ; src
    ld bc, Data_String2_end - Data_String2_start  ; count
    call Func_MemCopy
    ;; Turn on audio.
    ld a, AUDENA_ON
    ldh [rAUDENA], a
    ld a, $ff
    ldh [rAUDTERM], a
    ld a, $77
    ldh [rAUDVOL], a
    ;; Start puzzle mode.
    jp Main_PuzzleScreen

;;;=========================================================================;;;

SECTION "Strings", ROM0

Data_String1_start:
    DB "NEW GAME"
Data_String1_end:
Data_String2_start:
    DB "PASSWORD"
Data_String2_end:

;;;=========================================================================;;;
