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
    ld hl, Vram_BgTiles + 0 * sizeof_TILE  ; dest
    COPY_FROM_ROMX DataX_DeviceTiles_start, DataX_DeviceTiles_end
    ld hl, Vram_BgTiles + " " * sizeof_TILE  ; dest
    COPY_FROM_ROMX DataX_FontTiles_start, DataX_FontTiles_end
    ld hl, Vram_SharedTiles + $60 * sizeof_TILE  ; dest
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    ld hl, Vram_ObjTiles  ; dest
    COPY_FROM_ROMX DataX_ObjTiles_start, DataX_ObjTiles_end
    ;; Initialize window map.
    ld hl, Vram_WindowMap
    ld e, $2b  ; edge tile ID
    ld d, $24  ; middle tile ID
    call Func_WindowHorzBar  ; updates hl
    ld e, $25  ; edge tile ID
    ld d, $20  ; middle tile ID
    ld b, 3
    .windowLoop
    call Func_WindowHorzBar  ; preserves b and de, updates hl
    dec b
    jr nz, .windowLoop
    ld e, $2b  ; edge tile ID
    ld d, $24  ; middle tile ID
    call Func_WindowHorzBar
    ;; Initialize palettes.
    ld a, %11100100
    ldh [rBGP], a
    ldh [rOBP0], a
    ldh [rOBP1], a
    ;; Read summary data from SRAM.
    call Func_InitSaveSummaries
    ;; Turn on audio.
    call Func_InitAudio
    ;; Go to title screen.
    jp Main_TitleScreen

;;;=========================================================================;;;

;;; @param d Middle tile ID.
;;; @param e Edge tile ID.
;;; @param hl Pointer to the start of a VRAM map row.
;;; @return hl Pointer to the start of the next VRAM map row.
;;; @preserve b, de
Func_WindowHorzBar:
    ld a, e
    ld [hl+], a
    ld a, d
    ld c, SCRN_X_B - 2
    .loop
    ld [hl+], a
    dec c
    jr nz, .loop
    ld a, e
    ld [hl], a
    ld a, l
    or SCRN_VX_B - 1
    ld l, a
    inc hl
    ret

;;;=========================================================================;;;
