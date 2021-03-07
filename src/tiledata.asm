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

SECTION "BgTiles", ROMX
DataX_BgTiles_start::
    INCBIN "out/data/font.2bpp"
    INCBIN "out/data/portrait.2bpp"
    INCBIN "out/data/porvar.2bpp"
    INCBIN "out/data/cow.2bpp"
    INCBIN "out/data/devices.2bpp"
DataX_BgTiles_end::

;;;=========================================================================;;;

SECTION "ObjTiles", ROMX
DataX_ObjTiles_start::
    INCBIN "out/data/elephant.2bpp"
    INCBIN "out/data/goat.2bpp"
    INCBIN "out/data/mouse.2bpp"
    INCBIN "out/data/cursor.2bpp"
    INCBIN "out/data/smoke.2bpp"
DataX_ObjTiles_end::

;;;=========================================================================;;;
;;; Terrain tiles:

SECTION "SharedTerrainTiles", ROMX
DataX_SharedTerrainTiles_start::
    INCBIN "out/data/goal.2bpp"
    INCBIN "out/data/pipe.2bpp"
    INCBIN "out/data/teleporter.2bpp"
    INCBIN "out/data/forest.2bpp"
DataX_SharedTerrainTiles_end::

SECTION "BarnTiles", ROMX
DataX_BarnTiles_start::
    INCBIN "out/data/barn.2bpp"
DataX_BarnTiles_end::

SECTION "BridgeTiles", ROMX
DataX_BridgeTiles_start::
    INCBIN "out/data/bridge.2bpp"
DataX_BridgeTiles_end::

SECTION "CityTiles", ROMX
DataX_CityTiles_start::
    INCBIN "out/data/city.2bpp"
DataX_CityTiles_end::

SECTION "FarmTiles", ROMX
DataX_FarmTiles_start::
    INCBIN "out/data/farm.2bpp"
DataX_FarmTiles_end::

SECTION "MapTiles", ROMX
DataX_MapTiles_start::
    INCBIN "out/data/worldmap.2bpp"
DataX_MapTiles_end::

SECTION "MountainTiles", ROMX
DataX_MountainTiles_start::
    INCBIN "out/data/mountain.2bpp"
DataX_MountainTiles_end::

SECTION "RiverTiles", ROMX
DataX_RiverTiles_start::
    INCBIN "out/data/river.2bpp"
DataX_RiverTiles_end::

SECTION "SpaceTiles", ROMX
DataX_SpaceTiles_start::
    INCBIN "out/data/space.2bpp"
DataX_SpaceTiles_end::

;;;=========================================================================;;;
;;; Animated terrain tiles:

SECTION "CowBlinkTiles", ROMX
DataX_CowBlinkTiles_tile_arr::
    INCBIN "out/data/cowblink.2bpp"

SECTION "OceanTiles", ROMX
DataX_OceanTiles_tile_arr::
    INCBIN "out/data/ocean.2bpp"

SECTION "StarsTiles", ROMX
DataX_StarsTiles_tile_arr::
    INCBIN "out/data/stars.2bpp"

;;;=========================================================================;;;
