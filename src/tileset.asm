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

SKIP_TO_TILE: MACRO
    STATIC_ASSERT _NARG == 1
    ld hl, Vram_SharedTiles + ((\1) - $80) * sizeof_TILE
ENDM

;;;=========================================================================;;;

SECTION "TilesetState", WRAM0

Ram_LastTileset_u8:
    DB

;;; The global animation clock, used to drive looping animations.
Ram_AnimationClock_u8::
    DB

;;;=========================================================================;;;

SECTION "TilesetFunctions", ROM0

;;; Populates Vram_SharedTiles with tile data for the specified tileset.
;;; @prereq LCD is off.
;;; @param b The TILESET_* enum value.
Func_LoadTileset::
    ld hl, Vram_SharedTiles  ; dest
    ld a, b
    ld [Ram_LastTileset_u8], a
    if_ge TILESET_PUZZ_MIN, jr, _LoadTileset_Puzz
    if_lt TILESET_MAP_MIN, jr, _LoadTileset_Title
_LoadTileset_Map:
    push af
    COPY_FROM_ROMX DataX_SharedMapTiles_start, DataX_SharedMapTiles_end
    pop af
    if_eq TILESET_MAP_CITY, jp, _LoadTileset_MapCity
    if_eq TILESET_MAP_FOREST, jp, _LoadTileset_MapForest
    if_eq TILESET_MAP_SEWER, jp, _LoadTileset_MapSewer
    if_eq TILESET_MAP_SPACE, jp, _LoadTileset_MapSpace
    if_eq TILESET_MAP_WORLD, jp, _LoadTileset_MapWorld
    ret
_LoadTileset_Puzz:
    push af
    COPY_FROM_ROMX DataX_SharedTerrainTiles_start, DataX_SharedTerrainTiles_end
    pop af
    if_eq TILESET_PUZZ_CITY, jp, _LoadTileset_PuzzCity
    if_eq TILESET_PUZZ_FARM, jp, _LoadTileset_PuzzFarm
    if_eq TILESET_PUZZ_LAKE, jp, _LoadTileset_PuzzLake
    if_eq TILESET_PUZZ_MOUNTAIN, jp, _LoadTileset_PuzzMountain
    if_eq TILESET_PUZZ_SEWER, jp, _LoadTileset_PuzzSewer
    if_eq TILESET_PUZZ_SPACE, jp, _LoadTileset_PuzzSpace
    ret

_LoadTileset_Title:
    SKIP_TO_TILE $80
    COPY_FROM_ROMX DataX_TitleTiles_start, DataX_TitleTiles_end
    ret
_LoadTileset_MapCity:
    SKIP_TO_TILE $c0
    COPY_FROM_ROMX DataX_MapLaunchTiles_start, DataX_MapLaunchTiles_end
    SKIP_TO_TILE $d0
    COPY_FROM_ROMX DataX_MapCoverTiles_start, DataX_MapCoverTiles_end
    COPY_FROM_ROMX DataX_MapOfficeTiles_start, DataX_MapOfficeTiles_end
    SKIP_TO_TILE $e0
    COPY_FROM_ROMX DataX_MapSkylineTiles_start, DataX_MapSkylineTiles_end
    ret
_LoadTileset_MapForest:
    SKIP_TO_TILE $a0
    COPY_FROM_ROMX DataX_MapMountainTiles_start, DataX_MapMountainTiles_end
    SKIP_TO_TILE $b0
    COPY_FROM_ROMX DataX_MapTreeTiles_start, DataX_MapTreeTiles_end
    SKIP_TO_TILE $c0
    COPY_FROM_ROMX DataX_MapPipeTiles_start, DataX_MapPipeTiles_end
    SKIP_TO_TILE $d0
    COPY_FROM_ROMX DataX_MapBarnTiles_start, DataX_MapBarnTiles_end
    SKIP_TO_TILE $e0
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    COPY_FROM_ROMX DataX_MapRiverTiles_start, DataX_MapRiverTiles_end
    xld hl, DataX_OceanTiles_tile_arr
    jp Func_SetAnimatedTile
_LoadTileset_MapSewer:
    SKIP_TO_TILE $c0
    COPY_FROM_ROMX DataX_MapPipeTiles_start, DataX_MapPipeTiles_end
    SKIP_TO_TILE $d0
    COPY_FROM_ROMX DataX_MapBrickTiles_start, DataX_MapBrickTiles_end
    xld hl, DataX_OceanTiles_tile_arr
    jp Func_SetAnimatedTile
_LoadTileset_MapSpace:
    SKIP_TO_TILE $a0
    COPY_FROM_ROMX DataX_SpaceMapTiles_start, DataX_SpaceMapTiles_end
    SKIP_TO_TILE $fb
    COPY_FROM_ROMX DataX_MapStarsTiles_start, DataX_MapStarsTiles_end
    xld hl, DataX_TwinkleTiles_tile_arr
    jp Func_SetAnimatedTile
_LoadTileset_MapWorld:
    SKIP_TO_TILE $a0
    COPY_FROM_ROMX DataX_MapMountainTiles_start, DataX_MapMountainTiles_end
    SKIP_TO_TILE $b0
    COPY_FROM_ROMX DataX_MapTreeTiles_start, DataX_MapTreeTiles_end
    SKIP_TO_TILE $c0
    COPY_FROM_ROMX DataX_MapPipeTiles_start, DataX_MapPipeTiles_end
    SKIP_TO_TILE $d0
    COPY_FROM_ROMX DataX_MapBarnTiles_start, DataX_MapBarnTiles_end
    SKIP_TO_TILE $d4
    COPY_FROM_ROMX DataX_MapOfficeTiles_start, DataX_MapOfficeTiles_end
    SKIP_TO_TILE $e0
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    COPY_FROM_ROMX DataX_MapRiverTiles_start, DataX_MapRiverTiles_end
    SKIP_TO_TILE $fb
    COPY_FROM_ROMX DataX_MapStarsTiles_start, DataX_MapStarsTiles_end
    xld hl, DataX_OceanTiles_tile_arr
    jp Func_SetAnimatedTile
_LoadTileset_PuzzCity:
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    SKIP_TO_TILE $d0
    COPY_FROM_ROMX DataX_FenceChainTiles_start, DataX_FenceChainTiles_end
    SKIP_TO_TILE $e0
    COPY_FROM_ROMX DataX_CityTiles_start, DataX_CityTiles_end
    ret
_LoadTileset_PuzzFarm:
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    SKIP_TO_TILE $d0
    COPY_FROM_ROMX DataX_FenceWoodTiles_start, DataX_FenceWoodTiles_end
    SKIP_TO_TILE $f0
    COPY_FROM_ROMX DataX_BarnTiles_start, DataX_BarnTiles_end
    xld hl, DataX_CowBlinkTiles_tile_arr
    jp Func_SetAnimatedTile
_LoadTileset_PuzzLake:
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    COPY_FROM_ROMX DataX_BridgeTiles_start, DataX_BridgeTiles_end
    SKIP_TO_TILE $d0
    COPY_FROM_ROMX DataX_FenceWoodTiles_start, DataX_FenceWoodTiles_end
    xld hl, DataX_OceanTiles_tile_arr
    jp Func_SetAnimatedTile
_LoadTileset_PuzzMountain:
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    COPY_FROM_ROMX DataX_BridgeTiles_start, DataX_BridgeTiles_end
    SKIP_TO_TILE $d0
    COPY_FROM_ROMX DataX_MountainTiles_start, DataX_MountainTiles_end
    ret
_LoadTileset_PuzzSewer:
    COPY_FROM_ROMX DataX_EdgeTiles_start, DataX_EdgeTiles_end
    SKIP_TO_TILE $c0
    COPY_FROM_ROMX DataX_BridgeTiles_start, DataX_BridgeTiles_end
    SKIP_TO_TILE $e0
    COPY_FROM_ROMX DataX_BrickTiles_start, DataX_BrickTiles_end
    xld hl, DataX_OceanTiles_tile_arr
    jp Func_SetAnimatedTile
_LoadTileset_PuzzSpace:
    COPY_FROM_ROMX DataX_GirderTiles_start, DataX_GirderTiles_end
    SKIP_TO_TILE $e0
    COPY_FROM_ROMX DataX_SpaceTiles_start, DataX_SpaceTiles_end
    xld hl, DataX_StarsTiles_tile_arr
    jp Func_SetAnimatedTile

;;;=========================================================================;;;

;;; Increments the global animation clock, and updates the animated tile for
;;; the most recently loaded tileset.
;;; @prereq A tileset has been loaded.
;;; @prereq LCD is off, or VBlank has recently started.
Func_AnimateTiles::
    ;; Increment the animation clock, and store the new value in c.
    ld hl, Ram_AnimationClock_u8
    inc [hl]
    ld c, [hl]
    ;; Choose the correct animation (if any) for the current tileset.
    ld a, [Ram_LastTileset_u8]
    if_eq TILESET_MAP_CITY, ret
    if_eq TILESET_MAP_SPACE, jr, _AnimateTiles_Twinkle
    if_eq TILESET_PUZZ_CITY, ret
    if_eq TILESET_PUZZ_FARM, jr, _AnimateTiles_Cow
    if_eq TILESET_PUZZ_MOUNTAIN, ret
    if_eq TILESET_PUZZ_SPACE, jr, _AnimateTiles_Stars
_AnimateTiles_Ocean:
    ld a, c
    and %00001111
    ret nz
    ld a, c
    and %00010000
    ASSERT sizeof_TILE == 16
    ldb de, a
    xld hl, DataX_OceanTiles_tile_arr
    jr _AnimateTiles_Copy
_AnimateTiles_Cow:
    ld a, c
    and %01111111
    jr z, .blink
    if_ne 10, ret
    ld a, sizeof_TILE
    .blink
    ldb de, a
    xld hl, DataX_CowBlinkTiles_tile_arr
    jr _AnimateTiles_Copy
_AnimateTiles_Stars:
    ld a, c
    and %00000111
    ASSERT sizeof_TILE == 16
    swap a
    ldb de, a
    xld hl, DataX_StarsTiles_tile_arr
    jr _AnimateTiles_Copy
_AnimateTiles_Twinkle:
    ld a, c
    and %00000111
    ret nz
    ld a, c
    and %00011000
    ASSERT sizeof_TILE == 16
    rlca
    ldb de, a
    xld hl, DataX_TwinkleTiles_tile_arr
_AnimateTiles_Copy:
    add hl, de
    ;; fall through to Func_SetAnimatedTile

;;; @prereq LCD is off, or VBlank has recently started.
;;; @prereq Correct ROM bank for hl pointer is set.
;;; @param hl A pointer to the tile to copy.
Func_SetAnimatedTile:
    ld de, Vram_BgTiles + sizeof_TILE * ANIMATED_TILEID
    REPT sizeof_TILE - 1
    ld a, [hl+]
    ld [de], a
    inc e
    ENDR
    ld a, [hl]
    ld [de], a
    ret

;;;=========================================================================;;;
