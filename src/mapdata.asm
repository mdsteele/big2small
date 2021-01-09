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
INCLUDE "src/puzzle.inc"
INCLUDE "src/vram.inc"

;;;=========================================================================;;;

SECTION "WorldMapData", ROM0

Data_WorldTileMap_start::
    INCBIN "out/data/worldmap.map"
Data_WorldTileMap_end::
ASSERT @ - Data_WorldTileMap_start == SCRN_VX_B * SCRN_VY_B

;; BG map row/col positions for each puzzle node.
Data_PuzzleMapPositions_u8_pair_arr::
    DB 28, 6
    DB 25, 6
    DB 25, 8
    DB 25, 11
    DB 23, 8
    DB 23, 3
    DB 25, 3
    DB 20, 3
    DB 20, 7
ASSERT @ - Data_PuzzleMapPositions_u8_pair_arr == 2 * NUM_PUZZLES

;;;=========================================================================;;;
