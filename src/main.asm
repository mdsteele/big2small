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
    ;; Initialize shadow OAM.
    call Func_ClearOam
    ld a, 24
    ld [Ram_MouseL_oama + OAMA_Y], a
    ld [Ram_MouseR_oama + OAMA_Y], a
    ld a, 80
    ld [Ram_MouseL_oama + OAMA_X], a
    add 8
    ld [Ram_MouseR_oama + OAMA_X], a
    ld a, 16
    ld [Ram_MouseR_oama + OAMA_TILEID], a
    add 2
    ld [Ram_MouseL_oama + OAMA_TILEID], a
    ld a, OAMF_XFLIP
    ld [Ram_MouseL_oama + OAMA_FLAGS], a
    ld [Ram_MouseR_oama + OAMA_FLAGS], a
    ;; Enable VBlank interrupt.
    ld a, IEF_VBLANK
    ldh [rIE], a
    ei
    ;; Turn off the LCD.
    call Func_WaitForVblank
    ld a, LCDCF_OFF
    ld [rLCDC], a
    ;; Copy tiles to VRAM.
    ld hl, Vram_BgTiles + 16 * "!"                    ; dest
    ld de, Data_FontTiles_start                       ; src
    ld bc, Data_FontTiles_end - Data_FontTiles_start  ; count
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
    ;; Turn on the LCD.
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WIN9C00
    ldh [rLCDC], a
    ;; Turn on audio.
    ld a, AUDENA_ON
    ldh [rAUDENA], a
    ld a, $ff
    ldh [rAUDTERM], a
    ld a, $77
    ldh [rAUDVOL], a
    ;; Initialize music.
    ld c, BANK(Data_TitleMusic_song)
    ld hl, Data_TitleMusic_song
    call Func_MusicStart
Main_RunLoop:
    call Func_WaitForVblankAndPerformDma
    call Func_MusicUpdate
    ldh a, [rSCX]
    add 1
    ldh [rSCX], a
    jr Main_RunLoop

;;;=========================================================================;;;

SECTION "Strings", ROM0

Data_String1_start:
    DB "NEW GAME"
Data_String1_end:
Data_String2_start:
    DB "PASSWORD"
Data_String2_end:

;;;=========================================================================;;;
