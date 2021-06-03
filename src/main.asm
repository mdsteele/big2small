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
INCLUDE "src/macros.inc"

;;;=========================================================================;;;

;;; Store the stack at the back of WRAM.
SECTION "Stack", WRAM0[$DF00]
    DS $100
Ram_BottomOfStack:

;;;=========================================================================;;;

SECTION "Main", ROM0[$0150]
Main::
    ;; Determine whether we're running on a CGB-compatible device.
    if_eq BOOTUP_A_CGB, jr, .enableColor
    xor a
    jr .doneColor
    .enableColor
    ld a, 1
    .doneColor
    ldh [Hram_ColorEnabled_bool], a
    ;; Initialize stack and DMA routine.
    ld sp, Ram_BottomOfStack
    xcall FuncX_InitDmaCode
    ;; Enable VBlank interrupt.
    ld a, IEF_VBLANK
    ldh [rIE], a
    ei
    ;; Turn off the LCD.
    call Func_WaitForVBlank
    ld a, LCDCF_OFF
    ldh [rLCDC], a
    ;; Copy tiles to VRAM.
    ld hl, Vram_BgTiles  ; param: dest
    COPY_FROM_ROMX DataX_BgTiles_start, DataX_BgTiles_end
    ld hl, Vram_ObjTiles  ; param: dest
    COPY_FROM_ROMX DataX_ObjTiles_start, DataX_ObjTiles_end
    ;; Initialize global state.
    xcall FuncX_InitObjColorPalettes
    call Func_InitSaveSummaries
    call Func_InitAudio
    ;; Go to title screen.
    jp Main_TitleScreen

;;;=========================================================================;;;
