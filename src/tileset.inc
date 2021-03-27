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

;;; The ID of the background tile that is animated by Func_AnimateTerrain.
ANIMATED_TILE_ID EQU $68

;=============================================================================;

;;; Enum values for PUZZ_Tileset_u8:
RSRESET
TILESET_MAP_FOREST    RB 1
TILESET_MAP_SEWER     RB 1
TILESET_MAP_SPACE     RB 1
TILESET_MAP_WORLD     RB 1
TILESET_PUZZ_MIN      RB 0
TILESET_PUZZ_CITY     RB 1
TILESET_PUZZ_FARM     RB 1
TILESET_PUZZ_MOUNTAIN RB 1
TILESET_PUZZ_SEASIDE  RB 1
TILESET_PUZZ_SEWER    RB 1
TILESET_PUZZ_SPACE    RB 1

;=============================================================================;
