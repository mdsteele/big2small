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

SECTION "UtilityFunctions", ROM0

;;; Copies bytes.
;;; @param hl Destination start address.
;;; @param de Source start address.
;;; @param bc Num bytes to copy.
Func_MemCopy::
    .loop
    ld a, b
    or c
    ret z
    ld a, [de]
    ld [hl+], a
    inc de
    dec bc
    jr .loop

;;; Zeroes bytes.
;;; @param hl Destination start address.
;;; @param bc Num bytes to zero.
;;; @preserve de
Func_MemZero::
    .loop
    ld a, b
    or c
    ret z
    xor a
    ld [hl+], a
    dec bc
    jr .loop

;;;=========================================================================;;;

FADE_STEP_FRAMES EQU 7

;;; Fades the screen in over the course of a number of frames.  Music will
;;; continue to play during the fade.
;;; @prereq LCD is off.
Func_FadeIn::
    ld a, %01000000
    ldh [rBGP], a
    ldh [rOBP0], a
    ldh [rOBP1], a
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WIN9C00
    ldh [rLCDC], a
    ld b, FADE_STEP_FRAMES
    .loop1
    push bc
    call Func_MusicUpdate
    call Func_WaitForVblank
    pop bc
    dec b
    jr nz, .loop1
    ld a, %10010000
    ldh [rBGP], a
    ldh [rOBP0], a
    ldh [rOBP1], a
    ld b, FADE_STEP_FRAMES
    .loop2
    push bc
    call Func_MusicUpdate
    call Func_WaitForVblank
    pop bc
    dec b
    jr nz, .loop2
    ld a, %11100100
    ldh [rBGP], a
    ldh [rOBP0], a
    ldh [rOBP1], a
    ret

;;;=========================================================================;;;

;;; Blocks until the next VBlank.
Func_WaitForVblank::
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
Func_WaitForVblankAndPerformDma::
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

;;; Reads and returns state of D-pad/buttons.
;;; @return b The 8-bit button state.
;;; @preserve c, de, hl
Func_GetButtonState_b::
    ld a, P1F_GET_DPAD
    ld [rP1], a
    REPT 2  ; It takes a couple cycles to get an accurate reading.
    ld a, [rP1]
    ENDR
    cpl
    and $0f
    swap a
    ld b, a
    ld a, P1F_GET_BTN
    ld [rP1], a
    REPT 6  ; It takes several cycles to get an accurate reading.
    ld a, [rP1]
    ENDR
    cpl
    and $0f
    or b
    ld b, a
    ld a, P1F_GET_NONE
    ld [rP1], a
    ret

;;;=========================================================================;;;
