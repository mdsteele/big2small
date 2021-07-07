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
INCLUDE "src/vram.inc"

;;;=========================================================================;;;

FADE_STEP_FRAMES EQU 7

;;;=========================================================================;;;

SECTION "FadeFunctions", ROM0

;;; Waits for FADE_STEP_FRAMES frames (without syncing OAM), returning at the
;;; start of VBlank.
Func_FadeWait:
    ld b, FADE_STEP_FRAMES
    .loop
    push bc
    call Func_UpdateAudio
    call Func_WaitForVBlank
    pop bc
    dec b
    jr nz, .loop
    ret

;;; Reloads the current colorset palettes, but 1/2 faded to white.
;;; @prereq LCD is off, or VBlank has recently started.
;;; @prereq Color is enabled.
Func_FadeBgColorToHalfSaturation:
    xcall FuncX_Colorset_GetCurrentCsetPtr_hl
    ld a, BCPSF_AUTOINC
    ldh [rBCPS], a
    ld c, NUM_COLORS_PER_CPAL * NUM_CPALS_PER_CSET
    ;; For each color xBbbbbGg_gggRrrrr, compute x1Bbbb1G_ggg1Rrrr.
    .loop
    ld a, [hl+]   ; a = gggRrrrr
    ld e, a
    ld a, [hl+]   ; a = xBbbbbGg
    rrca          ; a = gxBbbbbG, carry = g
    ld d, a
    ld a, e       ; a = gggRrrrr
    rra           ; a = ggggRrrr (high bit g comes from carry)
    or %00010000  ; a = ggg1Rrrr
    ldh [rBCPD], a
    ld a, d       ; a = gxBbbbbG
    or %01000010  ; a = g1Bbbb1G (the high bit will be ignored)
    ldh [rBCPD], a
    dec c
    jr nz, .loop
    ret

;;; Reloads the current colorset palettes, but 3/4 faded to white.
;;; @prereq LCD is off, or VBlank has recently started.
;;; @prereq Color is enabled.
Func_FadeBgColorToQuarterSaturation:
    xcall FuncX_Colorset_GetCurrentCsetPtr_hl
    ld a, BCPSF_AUTOINC
    ldh [rBCPS], a
    ld c, NUM_COLORS_PER_CPAL * NUM_CPALS_PER_CSET
    ;; For each color xBbbbbGg_gggRrrrr, compute x11Bbb11_Ggg11Rrr.
    .loop
    ld a, [hl+]   ; a = gggRrrrr
    ld e, a
    ld a, [hl+]   ; a = xBbbbbGg
    rrca          ; a = gxBbbbbG
    rrca          ; a = GgxBbbbb
    ld d, a
    and %11000000 ; a = Gg000000
    ld b, a
    ld a, e       ; a = gggRrrrr
    srl a         ; a = 0gggRrrr
    srl a         ; a = 00gggRrr
    or b          ; a = GggggRrr
    or %00011000  ; a = Ggg11Rrr
    ldh [rBCPD], a
    ld a, d       ; a = GgxBbbbb
    or %01100011  ; a = G11Bbb11 (the high bit will be ignored)
    ldh [rBCPD], a
    dec c
    jr nz, .loop
    ret

;;;=========================================================================;;;

;;; Turns the LCD on and fades the screen in over the course of a number of
;;; frames.  Music will continue to play during the fade.  When this function
;;; returns, the VBlank period will have just started.
;;; @prereq LCD is off.
;;; @param d Display flags to use (combination of LCDCF_* values).
Func_FadeIn::
    ld a, d
    or LCDCF_ON
    push af
    ;; Check if color is enabled.
    ldh a, [Hram_ColorEnabled_bool]
    or a
    jr nz, _FadeIn_Color
_FadeIn_Grayscale:
    ;; Set grayscale palettes to 1/3 saturation.
    ld a, GRAYSCALE_PALETTE_13
    ldh [rBGP], a
    ldh [rOBP0], a
    ldh [rOBP1], a
    ;; Sync OAM and turn on the LCD, then wait for a few frames.
    call Func_PerformDma
    pop af
    or LCDCF_ON
    ldh [rLCDC], a
    call Func_FadeWait
    ;; Set grayscale palettes to 2/3 saturation, then wait for a few frames.
    ld a, GRAYSCALE_PALETTE_23
    ldh [rBGP], a
    ldh [rOBP0], a
    ldh [rOBP1], a
    call Func_FadeWait
    ;; Set grayscale palettes to full saturation.
    ld a, GRAYSCALE_PALETTE_0
    ldh [rBGP], a
    ldh [rOBP0], a
    ld a, GRAYSCALE_PALETTE_1
    ldh [rOBP1], a
    ret
_FadeIn_Color:
    ;; With the LCD still off, set BG color palettes to 1/4 saturation.
    call Func_FadeBgColorToQuarterSaturation
    ;; Sync OAM and turn on the LCD, but with objects disabled, then wait for a
    ;; few frames.
    call Func_PerformDma
    pop af
    push af
    and ~LCDCF_OBJON
    ldh [rLCDC], a
    call Func_FadeWait
    ;; Set BG color palettes to 1/2 saturation.
    call Func_FadeBgColorToHalfSaturation
    ;; Enable drawing objects, then wait for a few frames.
    pop af
    ldh [rLCDC], a
    call Func_FadeWait
    ;; Set all color palettes to full saturation, then wait one more frame so
    ;; that we can return at the start of VBlank.
    xcall FuncX_Colorset_Reload
    call Func_UpdateAudio
    call Func_WaitForVBlank
    ret

;;;=========================================================================;;;

;;; Fades the screen out over the course of a number of frames, then turns the
;;; LCD off.  Music will continue to play during the fade.
;;; @prereq LCD is on.
Func_FadeOut::
    ;; End the current frame and sync OAM.
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    ;; Check if color is enabled.
    ldh a, [Hram_ColorEnabled_bool]
    or a
    jr nz, _FadeOut_Color
_FadeOut_Grayscale:
    ;; Set grayscale palettes to 2/3 saturation, then wait for a few frames.
    ld a, GRAYSCALE_PALETTE_23
    ldh [rBGP], a
    ldh [rOBP0], a
    ldh [rOBP1], a
    call Func_FadeWait
    ;; Set grayscale palettes to 1/3 saturation, then wait for a few frames.
    ld a, GRAYSCALE_PALETTE_13
    ldh [rBGP], a
    ldh [rOBP0], a
    ldh [rOBP1], a
    call Func_FadeWait
    ;; Turn off the LCD.
    ld a, LCDCF_OFF
    ldh [rLCDC], a
    ret
_FadeOut_Color:
    ;; Wait one more frame (without syncing OAM this time), so that we have a
    ;; full VBlank period to work with.
    call Func_UpdateAudio
    call Func_WaitForVBlank
    ;; Set BG color palettes to 1/2 saturation, then wait for a few frames.
    call Func_FadeBgColorToHalfSaturation
    call Func_FadeWait
    ;; Set BG color palettes to 1/4 saturation, then disable objects and wait
    ;; for a few frames.
    call Func_FadeBgColorToQuarterSaturation
    ldh a, [rLCDC]
    and ~LCDCF_OBJON
    ldh [rLCDC], a
    call Func_FadeWait
    ;; Turn off the LCD.
    ld a, LCDCF_OFF
    ldh [rLCDC], a
    ret

;;;=========================================================================;;;
