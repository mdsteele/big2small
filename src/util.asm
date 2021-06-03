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

SECTION "MemFunctions", ROM0

;;; Copies bytes.
;;; @param hl Destination start address.
;;; @param de Source start address.
;;; @param bc Num bytes to copy.
;;; @return hl Destination end address.
Func_MemCopy::
    inc b
    bit 0, c
    jr nz, .odd
    inc c
    jr .even
    .loop
    ld a, [de]
    ld [hl+], a
    inc de
    dec c
    .odd
    ld a, [de]
    ld [hl+], a
    inc de
    .even
    dec c
    jr nz, .loop
    dec b
    jr nz, .loop
    ret

;;;=========================================================================;;;

SECTION "VBlankFunctions", ROM0

;;; Blocks until the next VBlank.
Func_WaitForVBlank::
    di    ; "Lock"
    xor a
    ldh [Hram_VBlank_bool], a
    .loop
    ei    ; "Await condition variable" (which is "notified" when an interrupt
    halt  ; occurs).  Note that the effect of an ei is delayed by one
    di    ; instruction, so no interrupt can occur here between ei and halt.
    ldh a, [Hram_VBlank_bool]
    or a
    jr z, .loop
    reti  ; "Unlock"

;;; Blocks until the next VBlank, then performs an OAM DMA.
Func_WaitForVBlankAndPerformDma::
    di    ; "Lock"
    xor a
    ldh [Hram_VBlank_bool], a
    .loop
    ei    ; "Await condition variable" (which is "notified" when an interrupt
    halt  ; occurs).  Note that the effect of an ei is delayed by one
    di    ; instruction, so no interrupt can occur here between ei and halt.
    ldh a, [Hram_VBlank_bool]
    or a
    jr z, .loop
    call Func_PerformDma
    reti  ; "Unlock"

;;;=========================================================================;;;

SECTION "ButtonFunctions", ROM0

;;; Reads the current state of the D-pad/buttons, and then updates the values
;;; of Ram_ButtonsHeld_u8 and Ram_ButtonsPressed_u8.
;;; @preserve de, hl
Func_UpdateButtonState::
    ;; Get current button state and store it in b.
    ld a, P1F_GET_DPAD
    ldh [rP1], a
    REPT 2  ; It takes a couple cycles to get an accurate reading.
    ldh a, [rP1]
    ENDR
    cpl
    and $0f
    swap a
    ld b, a
    ld a, P1F_GET_BTN
    ldh [rP1], a
    REPT 6  ; It takes several cycles to get an accurate reading.
    ldh a, [rP1]
    ENDR
    cpl
    and $0f
    or b
    ld b, a
    ld a, P1F_GET_NONE
    ldh [rP1], a
    ;; Update state variables.
    ld a, [Ram_ButtonsHeld_u8]
    cpl
    ld c, a
    ld a, b
    ld [Ram_ButtonsHeld_u8], a
    and c
    ld [Ram_ButtonsPressed_u8], a
    ret

SECTION "ButtonState", WRAM0

;;; ButtonsHeld: A bitfield indicating which buttons are currently being held.
Ram_ButtonsHeld_u8::
    DB

;;; ButtonsPressed: A bitfield indicating which buttons have been newly pressed
;;;   since the previous call to Func_UpdateButtonState.
Ram_ButtonsPressed_u8::
    DB

;;;=========================================================================;;;
