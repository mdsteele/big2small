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

;;; The BG color palette index to use for area map nodes and trail ticks.
TRAIL_PALETTE EQU 5

;;;=========================================================================;;;

SECTION "AreaMapColorFunctions", ROM0

;;; If color is enabled, sets the palette number for the specified trail tile.
;;; @param hl A pointer to BG map byte in VRAM for the trail tile.
;;; @preserve bc, de, hl, romb
Func_SetTrailTileColor::
    ;; Do nothing if color is disabled.
    ldh a, [Hram_ColorEnabled_bool]
    or a
    ret z
    ;; Switch to VRAM bank 1.
    ld a, 1
    ldh [rVBK], a
    ;; Set the palette for the tile that hl points to.
    ld [hl], TRAIL_PALETTE
    ;; Switch back to VRAM bank 0.
    xor a
    ldh [rVBK], a
    ret

;;;=========================================================================;;;

;;; @prereq Correct ROM bank for de pointer is set.
;;; @param de Pointer to the BG map data for the area.
Func_LoadAreaMapColor::
    ;; Copy the palette table into HRAM for later.
    ld hl, Data_AreaMapBgPalettes_u8_arr8
    ld c, LOW(Hram_AreaMapBgPalettes_u8_arr8)
    ld b, 8
    .hramLoop
    ld a, [hl+]
    ld [c], a
    inc c
    dec b
    jr nz, .hramLoop
    ;; Switch to VRAM bank 1.
    ld a, 1
    ldh [rVBK], a
    ;; Set the color palettes for the area map based on the tile IDs.
    ld hl, Vram_BgMap + SCRN_VX_B
    REPT SCRN_Y_B - 2
    call Func_LoadAreaMapColorRow
    ENDR
    ;; Set the color palette for the top and bottom rows of tiles (where the
    ;; area and puzzle titles go) to 0.
    xor a
    ld hl, Vram_BgMap
    ld c, SCRN_X_B
    .topRowLoop
    ld [hl+], a
    dec c
    jr nz, .topRowLoop
    ld hl, Vram_BgMap + SCRN_VX_B * (SCRN_Y_B - 1)
    ld c, SCRN_X_B
    .botRowLoop
    ld [hl+], a
    dec c
    jr nz, .botRowLoop
    ;; Switch back to VRAM bank 0.
    xor a
    ldh [rVBK], a
    ret

;;; @prereq Hram_AreaMapBgPalettes_u8_arr8 has been populated.
;;; @prereq Correct ROM bank for de pointer is set.
;;; @prereq VRAM bank is set to 1.
;;; @param de Pointer to start of area tile map row.
;;; @param hl Pointer to start of Vram_BgMap row.
;;; @return de Pointer to start of next area tile map row.
;;; @return hl Pointer to start of next Vram_BgMap row.
Func_LoadAreaMapColorRow:
    ld b, SCRN_X_B
    .colLoop
    ;; Get next tile map value.
    ld a, [de]
    inc de
    ;; Use bits 4-6 as an index into Hram_AreaMapBgPalettes_u8_arr8.
    and %01110000
    swap a
    add LOW(Hram_AreaMapBgPalettes_u8_arr8)
    ld c, a
    ld a, [c]
    ;; Write the palette from the table into VRAM.
    ld [hl+], a
    dec b
    jr nz, .colLoop
    ;; Set up hl for next row.
    ld bc, SCRN_VX_B - SCRN_X_B
    add hl, bc
    ret

;;; Maps from bits 4-6 of an area map tile ID to a color palette number.
Data_AreaMapBgPalettes_u8_arr8:
    DB TRAIL_PALETTE, 6, 1, 3, 7, 6, 4, 4

;;;=========================================================================;;;

SECTION "HramAreaMapBgPalettes", HRAM

;;; Helper memory for Func_LoadAreaMapColor that holds a temporary copy of
;;; Data_AreaMapBgPalettes_u8_arr8.
Hram_AreaMapBgPalettes_u8_arr8:
    DS 8

;;;=========================================================================;;;
