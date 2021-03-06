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

INCLUDE "src/macros.inc"
INCLUDE "src/tileset.inc"
INCLUDE "src/vram.inc"

;;;=========================================================================;;;

SKIP_TILES: MACRO
    STATIC_ASSERT _NARG == 1
    ld bc, (\1) * sizeof_TILE
    add hl, bc
ENDM

;;;=========================================================================;;;

SECTION "TilesetFunctions", ROM0

;;; Populates Vram_SharedTiles with tile data for the specified tileset.
;;; @param b The TILESET_* enum value.
Func_LoadTileset::
    push bc
    ld hl, Vram_SharedTiles  ; dest
    COPY_FROM_ROMX DataX_SharedTerrainTiles_start, DataX_SharedTerrainTiles_end
    pop af
    if_eq TILESET_CITY, jr, _LoadTileset_City
    if_eq TILESET_FARM, jr, _LoadTileset_Farm
    if_eq TILESET_MOUNTAIN, jr, _LoadTileset_Mountain
    if_eq TILESET_SEASIDE, jp, _LoadTileset_Seaside
    if_eq TILESET_SEWER, jp, _LoadTileset_Sewer
    if_eq TILESET_SPACE, jp, _LoadTileset_Space
_LoadTileset_City:
    SKIP_TILES $20
    COPY_FROM_ROMX DataX_CityTiles_start, DataX_CityTiles_end
    ret
_LoadTileset_Farm:
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    SKIP_TILES $10
    COPY_FROM_ROMX DataX_FarmTiles_start, DataX_FarmTiles_end
    SKIP_TILES $0c
    COPY_FROM_ROMX DataX_BarnTiles_start, DataX_BarnTiles_end
    ld hl, DataX_CowBlinkTiles_tile_arr
    jp Func_SetAnimatedTerrain
_LoadTileset_Mountain:
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    COPY_FROM_ROMX DataX_BridgeTiles_start, DataX_BridgeTiles_end
    SKIP_TILES $08
    COPY_FROM_ROMX DataX_MountainTiles_start, DataX_MountainTiles_end
    ret
_LoadTileset_Seaside:
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    COPY_FROM_ROMX DataX_BridgeTiles_start, DataX_BridgeTiles_end
    ld hl, DataX_OceanTiles_tile_arr
    jp Func_SetAnimatedTerrain
_LoadTileset_Sewer:
    COPY_FROM_ROMX DataX_EdgeTiles_start, DataX_EdgeTiles_end
    SKIP_TILES $0c
    COPY_FROM_ROMX DataX_BridgeTiles_start, DataX_BridgeTiles_end
    SKIP_TILES $08
    COPY_FROM_ROMX DataX_CityTiles_start, DataX_CityTiles_end
    ld hl, DataX_OceanTiles_tile_arr
    jp Func_SetAnimatedTerrain
_LoadTileset_Space:
    COPY_FROM_ROMX DataX_GirderTiles_start, DataX_GirderTiles_end
    SKIP_TILES $1f
    COPY_FROM_ROMX DataX_SpaceTiles_start, DataX_SpaceTiles_end
    ld hl, DataX_StarsTiles_tile_arr
    jp Func_SetAnimatedTerrain

;;; @param b The TILESET_* enum value.
;;; @param c The animation counter (0-255).
Func_AnimateTerrain::
    ld a, b
    if_eq TILESET_FARM, jr, _AnimateTerrain_Cow
    if_eq TILESET_SEASIDE, jr, _AnimateTerrain_Ocean
    if_eq TILESET_SEWER, jr, _AnimateTerrain_Ocean
    if_eq TILESET_SPACE, jr, _AnimateTerrain_Stars
    ret
_AnimateTerrain_Cow:
    ld a, c
    and %01111111
    jr z, .blink
    if_ne 10, ret
    ld a, sizeof_TILE
    .blink
    ldb de, a
    romb BANK(DataX_CowBlinkTiles_tile_arr)
    ld hl, DataX_CowBlinkTiles_tile_arr
    jr _AnimateTerrain_Copy
_AnimateTerrain_Ocean:
    ld a, c
    and %00001111
    ret nz
    ld a, c
    and %00010000
    ASSERT sizeof_TILE == 16
    ldb de, a
    romb BANK(DataX_OceanTiles_tile_arr)
    ld hl, DataX_OceanTiles_tile_arr
    jr _AnimateTerrain_Copy
_AnimateTerrain_Stars:
    ld a, c
    and %00000111
    ASSERT sizeof_TILE == 16
    swap a
    ldb de, a
    romb BANK(DataX_StarsTiles_tile_arr)
    ld hl, DataX_StarsTiles_tile_arr
_AnimateTerrain_Copy:
    add hl, de
    ;; fall through to Func_SetAnimatedTerrain

;;; @param hl A pointer to the tile to copy.
Func_SetAnimatedTerrain:
    ld de, Vram_BgTiles + sizeof_TILE * ANIMATED_TILE_ID
    REPT sizeof_TILE - 1
    ld a, [hl+]
    ld [de], a
    inc e
    ENDR
    ld a, [hl]
    ld [de], a
    ret

;;;=========================================================================;;;
