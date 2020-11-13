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

TERRAIN_COLS EQU 10
TERRAIN_ROWS EQU 9

;;;=========================================================================;;;

;;; PUZZ: Describes a puzzle.  PUZZ structs must be aligned to 16 bytes.
RSRESET
;;; StartE: Specifies the start position of the elephant.  The high nibble
;;;   gives the X position (0-9) and the low nibble gives the Y position (0-8).
PUZZ_StartE_u8 EQU (TERRAIN_COLS + 0)
;;; StartG: Specifies the start position of the goat, encoded as above.
PUZZ_StartG_u8 EQU (TERRAIN_COLS + 1)
;;; StartM: Specifies the start position of the mouse, encoded as above.
PUZZ_StartM_u8 EQU (TERRAIN_COLS + 2)
sizeof_PUZZ    EQU (16 * TERRAIN_ROWS)

;;;=========================================================================;;;
