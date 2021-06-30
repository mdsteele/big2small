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

SECTION "ColorsetState", WRAM0

Ram_LastBgColorset_u8:
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

SECTION "Colorset", ROMX

;;; Returns a pointer to the CSET struct for the most recently loaded colorset.
;;; @prereq Color is enabled, and a colorset has been loaded.
;;; @return hl A pointer to a CSET struct in BANK("Colorset").
FuncX_Colorset_GetCurrentCsetPtr_hl::
    ld a, [Ram_LastBgColorset_u8]
    rlca
    ldb bc, a
    ld hl, DataX_Colorset_Table_cset_ptr_arr
    add hl, bc
    deref hl
    ret

;;; If color is enabled, reloads the most recently set colorset into hardware.
;;; This takes a little while, and should not be performed while drawing the
;;; screen.
;;; @prereq LCD is off, or VBlank has recently started.
FuncX_Colorset_Reload::
    ;; If color is disabled, we're done.
    ldh a, [Hram_ColorEnabled_bool]
    or a
    ret z
    ;; Use the most recently set colorset enum value.
    ld a, [Ram_LastBgColorset_u8]
    ld c, a
    jr _Colorset_Load_GetPointer

;;; If color is enabled, sets the current colorset and loads the color palette
;;; data into hardware.  This takes a little while, and should not be performed
;;; while drawing the screen.
;;; @prereq LCD is off, or VBlank has recently started.
;;; @param c The chosen colorset.
FuncX_Colorset_Load::
    ;; If color is disabled, we're done.
    ldh a, [Hram_ColorEnabled_bool]
    or a
    ret z
    ;; Store the chosen colorset enum value in Ram_LastBgColorset_u8.
    ld a, c
    ld [Ram_LastBgColorset_u8], a
_Colorset_Load_GetPointer:
    ;; Store a pointer to the chosen colorset in hl.
    sla c
    ld b, 0
    ld hl, DataX_Colorset_Table_cset_ptr_arr
    add hl, bc
    deref hl
_Colorset_Load_BgPalettes:
    ;; Transfer BG color palette data.
    ld a, BCPSF_AUTOINC
    ldh [rBCPS], a
    ld c, sizeof_CSET
    .loop
    ld a, [hl+]
    ldh [rBCPD], a
    dec c
    jr nz, .loop
_Colorset_Load_PipeObjPalette:
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

DataX_Colorset_Table_cset_ptr_arr:
    .begin
    ASSERT @ - .begin == 2 * COLORSET_SPRING
    DW DataX_Colorset_Spring_cset
    ASSERT @ - .begin == 2 * COLORSET_SUMMER
    DW DataX_Colorset_Summer_cset
    ASSERT @ - .begin == 2 * COLORSET_AUTUMN
    DW DataX_Colorset_Autumn_cset
    ASSERT @ - .begin == 2 * COLORSET_WINTER
    DW DataX_Colorset_Winter_cset
    ASSERT @ - .begin == 2 * COLORSET_SEWER
    DW DataX_Colorset_Sewer_cset
    ASSERT @ - .begin == 2 * COLORSET_SPACE
    DW DataX_Colorset_Space_cset
    ASSERT @ - .begin == 2 * COLORSET_WORLD
    DW DataX_Colorset_World_cset
    ASSERT @ - .begin == 2 * NUM_COLORSETS

DataX_Colorset_Spring_cset:
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
ASSERT @ - .begin == sizeof_CSET

DataX_Colorset_Summer_cset:
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
ASSERT @ - .begin == sizeof_CSET

DataX_Colorset_Autumn_cset:
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
ASSERT @ - .begin == sizeof_CSET

DataX_Colorset_Winter_cset:
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
ASSERT @ - .begin == sizeof_CSET

DataX_Colorset_Sewer_cset:
    .begin
    ;; Palette 0 (menu)
    D_COLOR 255, 224, 255
    D_COLOR 192, 0, 192
    D_COLOR 96, 0, 96
    D_COLOR 0, 0, 0
    ;; Palette 1 (wood)
    D_COLOR 216, 216, 224
    D_COLOR 192, 128, 64
    D_COLOR 128, 96, 32
    D_COLOR 64, 32, 16
    ;; Palette 2 (apple)
    D_COLOR 216, 216, 224
    D_COLOR 255, 0, 0
    D_COLOR 0, 192, 0
    D_COLOR 0, 64, 0
    ;; Palette 3 (plants)
    D_COLOR 216, 216, 224
    D_COLOR 0, 255, 0
    D_COLOR 0, 128, 0
    D_COLOR 0, 64, 0
    ;; Palette 4 (water)
    D_COLOR 255, 192, 255
    D_COLOR 128, 192, 128
    D_COLOR 128, 96, 32
    D_COLOR 64, 32, 0
    ;; Palette 5 (cheese)
    D_COLOR 216, 216, 224
    D_COLOR 255, 192, 0
    D_COLOR 128, 96, 0
    D_COLOR 64, 48, 0
    ;; Palette 6 (walls)
    D_COLOR 216, 216, 224
    D_COLOR 128, 192, 128
    D_COLOR 96, 96, 128
    D_COLOR 0, 0, 16
    ;; Palette 7 (metal)
    D_COLOR 216, 216, 224
    D_COLOR 224, 192, 192
    D_COLOR 128, 96, 96
    D_COLOR 0, 0, 0
ASSERT @ - .begin == sizeof_CSET

DataX_Colorset_Space_cset:
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
ASSERT @ - .begin == sizeof_CSET

DataX_Colorset_World_cset:
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
    ;; Palette 2 (skyscrapers)
    D_COLOR 255, 255, 192
    D_COLOR 180, 144, 255
    D_COLOR 96, 112, 128
    D_COLOR 0, 0, 16
    ;; Palette 3 (trees)
    D_COLOR 255, 255, 192
    D_COLOR 0, 255, 0
    D_COLOR 0, 128, 0
    D_COLOR 0, 64, 0
    ;; Palette 4 (water)
    D_COLOR 255, 224, 192
    D_COLOR 180, 144, 255
    D_COLOR 112, 64, 64
    D_COLOR 64, 32, 0
    ;; Palette 5 (wheat)
    D_COLOR 255, 255, 192
    D_COLOR 255, 192, 0
    D_COLOR 128, 96, 0
    D_COLOR 64, 48, 0
    ;; Palette 6 (mountains)
    D_COLOR 255, 255, 192
    D_COLOR 192, 160, 160
    D_COLOR 128, 70, 70
    D_COLOR 32, 0, 0
    ;; Palette 7 (metal)
    D_COLOR 255, 255, 192
    D_COLOR 192, 192, 192
    D_COLOR 96, 96, 96
    D_COLOR 0, 0, 0
ASSERT @ - .begin == sizeof_CSET

;;;=========================================================================;;;
