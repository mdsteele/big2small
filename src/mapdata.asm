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

AREA_MAP_LENGTH EQU SCRN_X_B * (SCRN_Y_B - 2)
WORLD_MAP_LENGTH EQU SCRN_VX_B * SCRN_VY_B

;;;=========================================================================;;;

SECTION "CityTileMap", ROMX
DataX_CityTileMap_start::
    INCBIN "out/data/maps/city.map"
ASSERT @ - DataX_CityTileMap_start == AREA_MAP_LENGTH

SECTION "FarmTileMap", ROMX
DataX_FarmTileMap_start::
    INCBIN "out/data/maps/farm.map"
ASSERT @ - DataX_FarmTileMap_start == AREA_MAP_LENGTH

SECTION "ForestTileMap", ROMX
DataX_ForestTileMap_start::
    INCBIN "out/data/maps/forest.map"
ASSERT @ - DataX_ForestTileMap_start == AREA_MAP_LENGTH

SECTION "LakeTileMap", ROMX
DataX_LakeTileMap_start::
    INCBIN "out/data/maps/lake.map"
ASSERT @ - DataX_LakeTileMap_start == AREA_MAP_LENGTH

SECTION "MoonTileMap", ROMX
DataX_MoonTileMap_start::
    INCBIN "out/data/maps/moon.map"
ASSERT @ - DataX_MoonTileMap_start == AREA_MAP_LENGTH

SECTION "MountainTileMap", ROMX
DataX_MountainTileMap_start::
    INCBIN "out/data/maps/mountain.map"
ASSERT @ - DataX_MountainTileMap_start == AREA_MAP_LENGTH

SECTION "SewerTileMap", ROMX
DataX_SewerTileMap_start::
    INCBIN "out/data/maps/sewer.map"
ASSERT @ - DataX_SewerTileMap_start == AREA_MAP_LENGTH

SECTION "SpaceTileMap", ROMX
DataX_SpaceTileMap_start::
    INCBIN "out/data/maps/space.map"
ASSERT @ - DataX_SpaceTileMap_start == AREA_MAP_LENGTH

SECTION "Title2TileMap", ROMX
DataX_Title2TileMap_start::
    INCBIN "out/data/maps/title2.map"
ASSERT @ - DataX_Title2TileMap_start == 12 * 4

SECTION "WorldTileMap", ROMX
DataX_WorldTileMap_start::
    INCBIN "out/data/maps/world.map"
DataX_WorldTileMap_end::
ASSERT @ - DataX_WorldTileMap_start == WORLD_MAP_LENGTH

;;;=========================================================================;;;
