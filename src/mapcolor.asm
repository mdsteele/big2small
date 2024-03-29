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

;;; The BG color palette index to use for area map nodes and trail ticks.
TRAIL_PALETTE EQU 5

;;;=========================================================================;;;

SECTION "MapColorFunctions", ROM0

;;; If color is enabled, sets the palette number for the specified trail tile.
;;; @param hl A pointer to BG map byte in VRAM for the trail tile.
;;; @preserve bc, de, hl, romb
Func_SetTrailTileColor::
    ;; Do nothing if color is disabled.
    if_dmg ret
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
;;; @param b BG palette number to use for top/bottom rows.
;;; @param de Pointer to the BG map data for the area.
Func_LoadAreaMapColor::
    ;; Switch to VRAM bank 1.
    ld a, 1
    ldh [rVBK], a
    ;; Set the color palette for the top and bottom rows of tiles (where the
    ;; area and puzzle titles go) to b.
    ld a, b
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
    ;; Set the color palettes for the area map based on the tile IDs.
    ld hl, Data_AreaMapBgPalettes_u8_arr16  ; param: palette array
    call Func_LoadHramPalettes  ; preserves de
    ld hl, Vram_BgMap + SCRN_VX_B
    ld c, SCRN_Y_B - 2
    .rowLoop
    push bc
    call Func_LoadAreaMapColorRow
    pop bc
    dec c
    jr nz, .rowLoop
    ;; Switch back to VRAM bank 0.
    xor a
    ldh [rVBK], a
    ret

;;; @prereq Hram_MapBgPalettes_u8_arr16 has been populated.
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
    ;; Use bits 3-6 as an index into Hram_MapBgPalettes_u8_arr16.
    and %01111000
    rlca
    swap a
    add LOW(Hram_MapBgPalettes_u8_arr16)
    ld c, a
    ldh a, [c]
    ;; Write the palette from the table into VRAM.
    ld [hl+], a
    dec b
    jr nz, .colLoop
    ;; Set up hl for next row.
    ld bc, SCRN_VX_B - SCRN_X_B
    add hl, bc
    ret

;;;=========================================================================;;;

Func_LoadWorldMapColor::
    ;; Copy the palette table into HRAM for later.
    ld hl, Data_WorldMapBgPalettes_u8_arr16
    call Func_LoadHramPalettes
    ;; Switch to VRAM bank 1.
    ld a, 1
    ldh [rVBK], a
    ;; Load the color data into VRAM.
    ld hl, Vram_BgMap
    xld de, DataX_WorldTileMap_start
    ASSERT $400 == DataX_WorldTileMap_end - DataX_WorldTileMap_start
    REPT 4
    call Func_LoadWorldMapColorQuarter
    ENDR
    ;; Switch back to VRAM bank 0.
    xor a
    ldh [rVBK], a
    ret

;;; @prereq Hram_MapBgPalettes_u8_arr8 has been populated.
;;; @prereq Correct ROM bank for de pointer is set.
;;; @prereq VRAM bank is set to 1.
;;; @param de Pointer to start of world tile map quarter.
;;; @param hl Pointer to start of Vram_BgMap quarter.
;;; @return de Pointer to start of next area tile map quarter.
;;; @return hl Pointer to start of next Vram_BgMap quarter.
Func_LoadWorldMapColorQuarter:
    ;; Perform $100 iterations.
    ld b, 0
    .loop
    ;; Get next tile map value.
    ld a, [de]
    inc de
    ;; Use bits 3-6 as an index into Hram_WorldMapBgPalettes_u8_arr8.
    and %01111000
    rlca
    swap a
    add LOW(Hram_MapBgPalettes_u8_arr16)
    ld c, a
    ldh a, [c]
    ;; Write the palette from the table into VRAM.
    ld [hl+], a
    dec b
    jr nz, .loop
    ret

;;;=========================================================================;;;

;;; @param hl Pointer to u8_arr16 to copy into HRAM.
;;; @preserve de
Func_LoadHramPalettes:
    ld c, LOW(Hram_MapBgPalettes_u8_arr16)
    ld b, 16
    .hramLoop
    ld a, [hl+]
    ldh [c], a
    inc c
    dec b
    jr nz, .hramLoop
    ret

;;; Maps from bits 3-6 of an area map tile ID to a color palette number.
Data_AreaMapBgPalettes_u8_arr16:
    .begin
    DB TRAIL_PALETTE, 1, 1, 1, 6, 6, 3, 3, 7, 7, 6, 6, 4, 4, 4, 4
    ASSERT @ - .begin == 16

;;; Maps from bits 3-6 of a world map tile ID to a color palette number.
Data_WorldMapBgPalettes_u8_arr16:
    .begin
    DB 5, 7, 1, 1, 6, 4, 3, 3, 7, 7, 6, 2, 4, 4, 4, 4
    ASSERT @ - .begin == 16

;;;=========================================================================;;;

SECTION "HramMapBgPalettes", HRAM

;;; Helper memory for Func_LoadAreaMapColor that holds a temporary copy of
;;; Data_AreaMapBgPalettes_u8_arr8.
Hram_MapBgPalettes_u8_arr16:
    DS 16

;;;=========================================================================;;;
