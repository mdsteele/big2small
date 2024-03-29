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
INCLUDE "src/vram.inc"

;;;=========================================================================;;;

SECTION "BgTiles", ROMX

FuncX_BgTiles_Init::
    ld hl, Vram_BgTiles  ; param: dest
    COPY_FROM_SAME DataX_BgTiles_First_start, DataX_BgTiles_First_end
    if_cgb jr, .cgb
    COPY_FROM_SAME DataX_BgTiles_GoatDmg_start, DataX_BgTiles_GoatDmg_end
    jr .last
    .cgb
    COPY_FROM_SAME DataX_BgTiles_GoatCgb_start, DataX_BgTiles_GoatCgb_end
    .last
    COPY_FROM_SAME DataX_BgTiles_Last_start, DataX_BgTiles_Last_end
    ret

DataX_BgTiles_First_start:
    INCBIN "out/data/tiles/font.2bpp"
    INCBIN "out/data/tiles/portrait_e1.2bpp"
    INCBIN "out/data/tiles/portrait_e2.2bpp"
DataX_BgTiles_First_end:

DataX_BgTiles_GoatDmg_start:
    INCBIN "out/data/tiles/portrait_g1_dmg.2bpp"
    INCBIN "out/data/tiles/portrait_g2_dmg.2bpp"
DataX_BgTiles_GoatDmg_end:

DataX_BgTiles_GoatCgb_start:
    INCBIN "out/data/tiles/portrait_g1_cgb.2bpp"
    INCBIN "out/data/tiles/portrait_g2_cgb.2bpp"
DataX_BgTiles_GoatCgb_end:

DataX_BgTiles_Last_start:
    INCBIN "out/data/tiles/portrait_m.2bpp"
    INCBIN "out/data/tiles/cow.2bpp"
    INCBIN "out/data/tiles/devices.2bpp"
DataX_BgTiles_Last_end:

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

SECTION "SplashTiles", ROMX
DataX_SplashTiles_start::
    INCBIN "out/data/tiles/retro1.2bpp"
    INCBIN "out/data/tiles/retro2.2bpp"
DataX_SplashTiles_end::

SECTION "TitleTiles", ROMX
DataX_TitleTiles_start::
    INCBIN "out/data/tiles/url.2bpp"
    INCBIN "out/data/tiles/title1.2bpp"
    INCBIN "out/data/tiles/title2a.2bpp"
    INCBIN "out/data/tiles/title2b.2bpp"
    INCBIN "out/data/tiles/title2c.2bpp"
    INCBIN "out/data/tiles/title2d.2bpp"
    INCBIN "out/data/tiles/title3.2bpp"
DataX_TitleTiles_end::

;;;=========================================================================;;;
;;; Map terrain tiles:

SECTION "SharedMapTiles", ROMX
DataX_SharedMapTiles_start::
    INCBIN "out/data/tiles/map_trail.2bpp"
    DS 4 * sizeof_TILE
    INCBIN "out/data/tiles/map_sat.2bpp"
    DS 3 * sizeof_TILE
    INCBIN "out/data/tiles/map_fence.2bpp"
    INCBIN "out/data/tiles/map_bridge.2bpp"
DataX_SharedMapTiles_end::

SECTION "MapBarnTiles", ROMX
DataX_MapBarnTiles_start::
    INCBIN "out/data/tiles/map_barn.2bpp"
DataX_MapBarnTiles_end::

SECTION "MapBrickTiles", ROMX
DataX_MapBrickTiles_start::
    INCBIN "out/data/tiles/map_brick.2bpp"
DataX_MapBrickTiles_end::

SECTION "MapCoverTiles", ROMX
DataX_MapCoverTiles_start::
    INCBIN "out/data/tiles/map_cover.2bpp"
DataX_MapCoverTiles_end::

SECTION "MapLaunchTiles", ROMX
DataX_MapLaunchTiles_start::
    INCBIN "out/data/tiles/map_launch.2bpp"
DataX_MapLaunchTiles_end::

SECTION "MapMoonTiles", ROMX
DataX_MapMoonTiles_start::
    INCBIN "out/data/tiles/map_moon.2bpp"
DataX_MapMoonTiles_end::

SECTION "MapMountainTiles", ROMX
DataX_MapMountainTiles_start::
    INCBIN "out/data/tiles/map_mountain.2bpp"
DataX_MapMountainTiles_end::

SECTION "MapOfficeTiles", ROMX
DataX_MapOfficeTiles_start::
    INCBIN "out/data/tiles/map_office.2bpp"
DataX_MapOfficeTiles_end::

SECTION "MapPipeTiles", ROMX
DataX_MapPipeTiles_start::
    INCBIN "out/data/tiles/map_silo.2bpp"
    INCBIN "out/data/tiles/map_pipe.2bpp"
DataX_MapPipeTiles_end::

SECTION "MapRiverTiles", ROMX
DataX_MapRiverTiles_start::
    INCBIN "out/data/tiles/map_river.2bpp"
DataX_MapRiverTiles_end::

SECTION "MapStarsTiles", ROMX
DataX_MapStarsTiles_start::
    INCBIN "out/data/tiles/map_stars.2bpp"
DataX_MapStarsTiles_end::

SECTION "MapTreeTiles", ROMX
DataX_MapTreeTiles_start::
    INCBIN "out/data/tiles/map_tree.2bpp"
DataX_MapTreeTiles_end::

SECTION "MapSkylineTiles", ROMX
DataX_MapSkylineTiles_start::
    INCBIN "out/data/tiles/map_skyline.2bpp"
DataX_MapSkylineTiles_end::

SECTION "SpaceMapTiles", ROMX
DataX_SpaceMapTiles_start::
    INCBIN "out/data/tiles/map_station.2bpp"
    DS 2 * sizeof_TILE
    INCBIN "out/data/tiles/map_earth.2bpp"
    INCBIN "out/data/tiles/map_ship.2bpp"
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
    DS 1 * sizeof_TILE
    INCBIN "out/data/tiles/ship.2bpp"
    INCBIN "out/data/tiles/thrust.2bpp"
DataX_GirderTiles_end::

SECTION "LaunchTiles", ROMX
DataX_LaunchTiles_start::
    INCBIN "out/data/tiles/launch.2bpp"
DataX_LaunchTiles_end::

SECTION "MountainTiles", ROMX
DataX_MountainTiles_start::
    INCBIN "out/data/tiles/mountain.2bpp"
DataX_MountainTiles_end::

SECTION "PebbleTiles", ROMX
DataX_PebbleTiles_start::
    INCBIN "out/data/tiles/pebble.2bpp"
DataX_PebbleTiles_end::

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
