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
INCLUDE "src/puzzle.inc"

;;;=========================================================================;;;

D_COLOR: MACRO
    IF _NARG < 3
    FAIL "Too few arguments to D_COLOR macro"
    ELIF _NARG > 3
    FAIL "Too many arguments to D_COLOR macro"
    ENDC
    DW (((\3) >> 3) << 10) | (((\2) >> 3) << 5) | ((\1) >> 3)
ENDM

;;;=========================================================================;;;

SECTION "ColorState", HRAM
Hram_ColorEnabled_bool::
    DB

;;;=========================================================================;;;

SECTION "ObjColorPalettes", ROMX

;;; If color is enabled, transfers object color palette data.
FuncX_InitObjColorPalettes::
    ;; If color is disabled, we're done.
    ldh a, [Hram_ColorEnabled_bool]
    or a
    ret z
    ;; Transfer object color palette data.
    ld a, OCPSF_AUTOINC
    ldh [rOCPS], a
    ld hl, DataX_ObjColorPalettes_start
    ld c, DataX_ObjColorPalettes_end - DataX_ObjColorPalettes_start
    .loop
    ld a, [hl+]
    ldh [rOCPD], a
    dec c
    jr nz, .loop
    ret

DataX_ObjColorPalettes_start:
    ;; Palette 0 (arrows)
    D_COLOR 255, 255, 255
    D_COLOR 255, 255, 255
    D_COLOR 128, 128, 128
    D_COLOR 0, 0, 0
    ;; Palette 1 (elephant)
    D_COLOR 255, 255, 255
    D_COLOR 192, 192, 192
    D_COLOR 15, 139, 172
    D_COLOR 48, 48, 98
    ;; Palette 2 (goat)
    D_COLOR 255, 255, 255
    D_COLOR 224, 224, 224
    D_COLOR 192, 192, 128
    D_COLOR 70, 70, 70
    ;; Palette 3 (mouse)
    D_COLOR 255, 255, 255
    D_COLOR 172, 96, 139
    D_COLOR 98, 48, 48
    D_COLOR 56, 15, 15
    ;; Palette 4 (smoke)
    D_COLOR 255, 255, 255
    D_COLOR 192, 128, 224
    D_COLOR 96, 64, 128
    D_COLOR 0, 0, 0
DataX_ObjColorPalettes_end:

;;;=========================================================================;;;

SECTION "BgColorPalettes", ROMX

;;; If color is enabled, transfers the specified BG color palette data.
;;; @param c The chosen colorset.
FuncX_SetBgColorPalettes::
    ;; If color is disabled, we're done.
    ldh a, [Hram_ColorEnabled_bool]
    or a
    ret z
    ;; Store a pointer to the chosen colorset in hl.
    sla c
    ld b, 0
    ld hl, DataX_BgColorPalettes_Colorsets_ptr_arr
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
_SetBgColorPalettes_BgPalettes:
    ;; Transfer BG color palette data.
    ld a, BCPSF_AUTOINC
    ldh [rBCPS], a
    ld c, NUM_BG_CPAL * sizeof_CPAL
    .loop
    ld a, [hl+]
    ldh [rBCPD], a
    dec c
    jr nz, .loop
_SetBgColorPalettes_PipeObjPalette:
    ;; Copy the last BG palette to object palette 7 (for pipe terrain).
    ld bc, -sizeof_CPAL
    add hl, bc
    ld a, OCPSF_AUTOINC | (7 * sizeof_CPAL)
    ldh [rOCPS], a
    ld c, sizeof_CPAL
    .loop
    ld a, [hl+]
    ldh [rOCPD], a
    dec c
    jr nz, .loop
    ret

DataX_BgColorPalettes_Colorsets_ptr_arr:
    .begin
    ASSERT @ - .begin == 2 * COLORSET_SPRING
    DW DataX_BgColorPalettes_Spring_cpal_arr
    ASSERT @ - .begin == 2 * COLORSET_SUMMER
    DW DataX_BgColorPalettes_Summer_cpal_arr
    ASSERT @ - .begin == 2 * COLORSET_AUTUMN
    DW DataX_BgColorPalettes_Autumn_cpal_arr
    ASSERT @ - .begin == 2 * COLORSET_WINTER
    DW DataX_BgColorPalettes_Winter_cpal_arr
    ASSERT @ - .begin == 2 * COLORSET_SPACE
    DW DataX_BgColorPalettes_Space_cpal_arr

DataX_BgColorPalettes_Spring_cpal_arr:
    .begin
    ;; Palette 0 (menu)
    D_COLOR 255, 255, 232
    D_COLOR 192, 224, 128
    D_COLOR 64, 128, 0
    D_COLOR 0, 64, 0
    ;; Palette 1 (wood)
    D_COLOR 255, 255, 192
    D_COLOR 192, 128, 64
    D_COLOR 128, 96, 32
    D_COLOR 64, 32, 16
    ;; Palette 2 (apple)
    D_COLOR 255, 255, 192
    D_COLOR 224, 255, 96
    D_COLOR 0, 192, 0
    D_COLOR 0, 64, 0
    ;; Palette 3 (plants)
    D_COLOR 255, 255, 192
    D_COLOR 0, 255, 0
    D_COLOR 0, 128, 0
    D_COLOR 0, 64, 0
    ;; Palette 4 (water)
    D_COLOR 255, 255, 192
    D_COLOR 0, 196, 255
    D_COLOR 128, 96, 32
    D_COLOR 64, 32, 0
    ;; Palette 5 (cheese)
    D_COLOR 255, 255, 192
    D_COLOR 255, 192, 0
    D_COLOR 128, 96, 0
    D_COLOR 64, 48, 0
    ;; Palette 6 (brick)
    D_COLOR 255, 255, 192
    D_COLOR 192, 160, 160
    D_COLOR 128, 70, 70
    D_COLOR 32, 0, 0
    ;; Palette 7 (metal)
    D_COLOR 255, 255, 192
    D_COLOR 192, 192, 192
    D_COLOR 96, 96, 96
    D_COLOR 0, 0, 0
ASSERT @ - .begin == NUM_BG_CPAL * sizeof_CPAL

DataX_BgColorPalettes_Summer_cpal_arr:
    .begin
    ;; Palette 0 (menu)
    D_COLOR 255, 232, 216
    D_COLOR 96, 192, 96
    D_COLOR 64, 128, 64
    D_COLOR 0, 32, 0
    ;; Palette 1 (wood)
    D_COLOR 255, 240, 224
    D_COLOR 192, 128, 64
    D_COLOR 128, 96, 32
    D_COLOR 64, 32, 16
    ;; Palette 2 (apple)
    D_COLOR 255, 240, 224
    D_COLOR 255, 160, 0
    D_COLOR 128, 192, 0
    D_COLOR 0, 64, 0
    ;; Palette 3 (plants)
    D_COLOR 255, 240, 224
    D_COLOR 0, 208, 0
    D_COLOR 0, 128, 0
    D_COLOR 0, 64, 0
    ;; Palette 4 (water)
    D_COLOR 255, 240, 224
    D_COLOR 0, 196, 255
    D_COLOR 128, 96, 32
    D_COLOR 64, 32, 0
    ;; Palette 5 (cheese)
    D_COLOR 255, 240, 224
    D_COLOR 255, 192, 0
    D_COLOR 128, 96, 0
    D_COLOR 64, 48, 0
    ;; Palette 6 (brick)
    D_COLOR 255, 240, 224
    D_COLOR 192, 160, 160
    D_COLOR 128, 70, 70
    D_COLOR 32, 0, 0
    ;; Palette 7 (metal)
    D_COLOR 255, 240, 224
    D_COLOR 192, 192, 192
    D_COLOR 96, 96, 96
    D_COLOR 0, 0, 0
ASSERT @ - .begin == NUM_BG_CPAL * sizeof_CPAL

DataX_BgColorPalettes_Autumn_cpal_arr:
    .begin
    ;; Palette 0 (menu)
    D_COLOR 255, 255, 255
    D_COLOR 192, 96, 0
    D_COLOR 96, 48, 0
    D_COLOR 0, 0, 0
    ;; Palette 1 (wood)
    D_COLOR 255, 224, 192
    D_COLOR 192, 128, 64
    D_COLOR 128, 96, 32
    D_COLOR 64, 32, 16
    ;; Palette 2 (apple)
    D_COLOR 255, 224, 192
    D_COLOR 255, 0, 0
    D_COLOR 0, 192, 0
    D_COLOR 0, 64, 0
    ;; Palette 3 (plants)
    D_COLOR 255, 224, 192
    D_COLOR 255, 128, 0
    D_COLOR 128, 64, 0
    D_COLOR 64, 32, 0
    ;; Palette 4 (water)
    D_COLOR 255, 224, 192
    D_COLOR 196, 128, 255
    D_COLOR 128, 96, 32
    D_COLOR 64, 32, 0
    ;; Palette 5 (cheese)
    D_COLOR 255, 224, 192
    D_COLOR 255, 192, 0
    D_COLOR 128, 96, 0
    D_COLOR 64, 48, 0
    ;; Palette 6 (brick)
    D_COLOR 255, 224, 192
    D_COLOR 192, 160, 160
    D_COLOR 128, 70, 70
    D_COLOR 32, 0, 0
    ;; Palette 7 (metal)
    D_COLOR 255, 224, 192
    D_COLOR 192, 192, 192
    D_COLOR 96, 96, 96
    D_COLOR 0, 0, 0
ASSERT @ - .begin == NUM_BG_CPAL * sizeof_CPAL

DataX_BgColorPalettes_Winter_cpal_arr:
    .begin
    ;; Palette 0 (menu)
    D_COLOR 255, 232, 232
    D_COLOR 224, 128, 128
    D_COLOR 128, 0, 0
    D_COLOR 64, 0, 0
    ;; Palette 1 (wood)
    D_COLOR 255, 255, 255
    D_COLOR 192, 128, 64
    D_COLOR 128, 96, 32
    D_COLOR 64, 32, 16
    ;; Palette 2 (apple)
    D_COLOR 255, 255, 255
    D_COLOR 192, 0, 80
    D_COLOR 0, 96, 0
    D_COLOR 0, 64, 0
    ;; Palette 3 (plants)
    D_COLOR 255, 255, 255
    D_COLOR 224, 224, 224
    D_COLOR 64, 128, 64
    D_COLOR 0, 64, 0
    ;; Palette 4 (water)
    D_COLOR 255, 255, 255
    D_COLOR 192, 224, 255
    D_COLOR 128, 96, 32
    D_COLOR 64, 32, 0
    ;; Palette 5 (cheese)
    D_COLOR 255, 255, 255
    D_COLOR 255, 192, 0
    D_COLOR 128, 96, 0
    D_COLOR 64, 48, 0
    ;; Palette 6 (brick)
    D_COLOR 255, 255, 255
    D_COLOR 192, 160, 160
    D_COLOR 128, 70, 70
    D_COLOR 32, 0, 0
    ;; Palette 7 (metal)
    D_COLOR 255, 255, 255
    D_COLOR 192, 192, 192
    D_COLOR 96, 96, 96
    D_COLOR 0, 0, 0
ASSERT @ - .begin == NUM_BG_CPAL * sizeof_CPAL

DataX_BgColorPalettes_Space_cpal_arr:
    .begin
    ;; Palette 0 (menu)
    D_COLOR 255, 224, 255
    D_COLOR 192, 0, 192
    D_COLOR 96, 0, 96
    D_COLOR 0, 0, 0
    ;; Palette 1 (wood)
    D_COLOR 255, 232, 240
    D_COLOR 192, 128, 64
    D_COLOR 128, 96, 32
    D_COLOR 64, 32, 16
    ;; Palette 2 (apple)
    D_COLOR 255, 232, 240
    D_COLOR 255, 0, 0
    D_COLOR 0, 192, 0
    D_COLOR 0, 64, 0
    ;; Palette 3 (plants)
    D_COLOR 255, 232, 240
    D_COLOR 0, 255, 0
    D_COLOR 0, 128, 0
    D_COLOR 0, 64, 0
    ;; Palette 4 (stars)
    D_COLOR 255, 255, 255
    D_COLOR 170, 170, 170
    D_COLOR 85, 85, 85
    D_COLOR 0, 0, 0
    ;; Palette 5 (cheese)
    D_COLOR 255, 232, 240
    D_COLOR 255, 192, 0
    D_COLOR 128, 96, 0
    D_COLOR 64, 48, 0
    ;; Palette 6 (walls)
    D_COLOR 255, 232, 240
    D_COLOR 192, 192, 224
    D_COLOR 96, 96, 128
    D_COLOR 0, 0, 16
    ;; Palette 7 (metal)
    D_COLOR 255, 232, 240
    D_COLOR 192, 224, 192
    D_COLOR 96, 128, 96
    D_COLOR 0, 0, 0
ASSERT @ - .begin == NUM_BG_CPAL * sizeof_CPAL

;;;=========================================================================;;;
