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

INCLUDE "src/vram.inc"

;;;=========================================================================;;;

SECTION "BgTiles", ROMX
DataX_BgTiles_start::
    INCBIN "out/data/tiles/font.2bpp"
    INCBIN "out/data/tiles/portrait.2bpp"
    INCBIN "out/data/tiles/porvar.2bpp"
    INCBIN "out/data/tiles/cow.2bpp"
    INCBIN "out/data/tiles/devices.2bpp"
DataX_BgTiles_end::

;;;=========================================================================;;;

SECTION "ObjTiles", ROMX
DataX_ObjTiles_start::
    INCBIN "out/data/tiles/elephant.2bpp"
    INCBIN "out/data/tiles/goat.2bpp"
    INCBIN "out/data/tiles/mouse.2bpp"
    INCBIN "out/data/tiles/cursor.2bpp"
    INCBIN "out/data/tiles/smoke.2bpp"
    INCBIN "out/data/tiles/mini.2bpp"
DataX_ObjTiles_end::

;;;=========================================================================;;;
;;; Title screen tiles:

SECTION "UrlTiles", ROMX
DataX_UrlTiles_start::
    INCBIN "out/data/tiles/url.2bpp"
DataX_UrlTiles_end::

;;;=========================================================================;;;
;;; Map terrain tiles:

SECTION "SharedMapTiles", ROMX
DataX_SharedMapTiles_start::
    INCBIN "out/data/tiles/map_trail.2bpp"
    DS 12 * sizeof_TILE
    INCBIN "out/data/tiles/map_fence.2bpp"
    DS 1 * sizeof_TILE
    INCBIN "out/data/tiles/map_bridge.2bpp"
DataX_SharedMapTiles_end::

SECTION "CityMapTiles", ROMX
DataX_CityMapTiles_start::
    INCBIN "out/data/tiles/map_launch.2bpp"
    INCBIN "out/data/tiles/map_office.2bpp"
    DS 1 * sizeof_TILE
    INCBIN "out/data/tiles/map_skyline.2bpp"
DataX_CityMapTiles_end::

SECTION "ForestMapTiles", ROMX
DataX_ForestMapTiles_start::
    INCBIN "out/data/tiles/map_mountain.2bpp"
    DS 1 * sizeof_TILE
    INCBIN "out/data/tiles/map_tree.2bpp"
    DS 6 * sizeof_TILE
    INCBIN "out/data/tiles/map_silo.2bpp"
    DS 13 * sizeof_TILE
    INCBIN "out/data/tiles/map_barn.2bpp"
DataX_ForestMapTiles_end::

SECTION "MapRiverTiles", ROMX
DataX_MapRiverTiles_start::
    INCBIN "out/data/tiles/map_river.2bpp"
DataX_MapRiverTiles_end::

SECTION "SewerMapTiles", ROMX
DataX_SewerMapTiles_start::
    INCBIN "out/data/tiles/map_pipe.2bpp"
    INCBIN "out/data/tiles/map_brick.2bpp"
DataX_SewerMapTiles_end::

SECTION "SpaceMapTiles", ROMX
DataX_SpaceMapTiles_start::
    INCBIN "out/data/tiles/map_station.2bpp"
    DS 2 * sizeof_TILE
    INCBIN "out/data/tiles/map_earth.2bpp"
    DS 3 * sizeof_TILE
    INCBIN "out/data/tiles/map_ship.2bpp"
    DS 2 * sizeof_TILE
    INCBIN "out/data/tiles/map_stars.2bpp"
DataX_SpaceMapTiles_end::

;;;=========================================================================;;;
;;; Puzzle terrain tiles:

SECTION "SharedTerrainTiles", ROMX
DataX_SharedTerrainTiles_start::
    INCBIN "out/data/tiles/goal.2bpp"
    INCBIN "out/data/tiles/pipe.2bpp"
    INCBIN "out/data/tiles/teleporter.2bpp"
    INCBIN "out/data/tiles/forest.2bpp"
DataX_SharedTerrainTiles_end::

SECTION "BarnTiles", ROMX
DataX_BarnTiles_start::
    INCBIN "out/data/tiles/barn.2bpp"
DataX_BarnTiles_end::

SECTION "BrickTiles", ROMX
DataX_BrickTiles_start::
    INCBIN "out/data/tiles/brick.2bpp"
DataX_BrickTiles_end::

SECTION "BridgeTiles", ROMX
DataX_BridgeTiles_start::
    INCBIN "out/data/tiles/bridge.2bpp"
DataX_BridgeTiles_end::

SECTION "CityTiles", ROMX
DataX_CityTiles_start::
    INCBIN "out/data/tiles/city.2bpp"
DataX_CityTiles_end::

SECTION "EdgeTiles", ROMX
DataX_EdgeTiles_start::
    INCBIN "out/data/tiles/edge.2bpp"
DataX_EdgeTiles_end::

SECTION "FenceChainTiles", ROMX
DataX_FenceChainTiles_start::
    INCBIN "out/data/tiles/fence_chain.2bpp"
DataX_FenceChainTiles_end::

SECTION "FenceWoodTiles", ROMX
DataX_FenceWoodTiles_start::
    INCBIN "out/data/tiles/fence_wood.2bpp"
DataX_FenceWoodTiles_end::

SECTION "GirderTiles", ROMX
DataX_GirderTiles_start::
    INCBIN "out/data/tiles/girder.2bpp"
DataX_GirderTiles_end::

SECTION "MountainTiles", ROMX
DataX_MountainTiles_start::
    INCBIN "out/data/tiles/mountain.2bpp"
DataX_MountainTiles_end::

SECTION "RiverTiles", ROMX
DataX_RiverTiles_start::
    INCBIN "out/data/tiles/river.2bpp"
DataX_RiverTiles_end::


SECTION "SpaceTiles", ROMX
DataX_SpaceTiles_start::
    INCBIN "out/data/tiles/space.2bpp"
DataX_SpaceTiles_end::

;;;=========================================================================;;;
;;; Animated terrain tiles:

SECTION "CowBlinkTiles", ROMX
DataX_CowBlinkTiles_tile_arr::
    INCBIN "out/data/tiles/cowblink.2bpp"

SECTION "OceanTiles", ROMX
DataX_OceanTiles_tile_arr::
    INCBIN "out/data/tiles/ocean.2bpp"

SECTION "StarsTiles", ROMX
DataX_StarsTiles_tile_arr::
    INCBIN "out/data/tiles/stars.2bpp"

SECTION "TwinkleTiles", ROMX
DataX_TwinkleTiles_tile_arr::
    INCBIN "out/data/tiles/twinkle.2bpp"

;;;=========================================================================;;;
