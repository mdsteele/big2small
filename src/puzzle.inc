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

;;; The dimensions of a puzzle's terrain grid:
TERRAIN_COLS EQU 10
TERRAIN_ROWS EQU 9

;;; Bit indices for ANIM_MoveDirs_u8:
DIRB_NORTH EQU 3
DIRB_SOUTH EQU 2
DIRB_EAST  EQU 1
DIRB_WEST  EQU 0

;;; Flags for ANIM_MoveDirs_u8, and enum values for ANIM_Facing_u8:
DIRF_NORTH EQU (1 << DIRB_NORTH)
DIRF_SOUTH EQU (1 << DIRB_SOUTH)
DIRF_EAST  EQU (1 << DIRB_EAST)
DIRF_WEST  EQU (1 << DIRB_WEST)

;;; Enum values for Ram_SelectedAnimal_u8:
ANIMAL_ELEPHANT EQU 0
ANIMAL_GOAT     EQU 1
ANIMAL_MOUSE    EQU 2

;;;=========================================================================;;;

;;; ANIM: Describes an animal character.
RSRESET
;;; Position: The animal's current position.  The high nibble gives the Y
;;;   position (0-8) and the low nibble gives the X position (0-9).
ANIM_Position_u8    RB 1
;;; Facing: Which direction the animal is currently facing.  This should be set
;;;   to one of the DIRF_* constants.
ANIM_Facing_u8      RB 1
sizeof_ANIM         RB 0

;;;=========================================================================;;;

;;; PUZZ: Describes a puzzle.  PUZZ structs must be aligned to 16 bytes.
RSRESET
;;; StartE: Specifies the start position of the elephant.  The high nibble
;;;   gives the Y position (0-8) and the low nibble gives the X position (0-9).
PUZZ_StartE_u8 EQU (TERRAIN_COLS + 0)
;;; StartG: Specifies the start position of the goat, encoded as above.
PUZZ_StartG_u8 EQU (TERRAIN_COLS + 1)
;;; StartM: Specifies the start position of the mouse, encoded as above.
PUZZ_StartM_u8 EQU (TERRAIN_COLS + 2)
sizeof_PUZZ    EQU (16 * TERRAIN_ROWS)

;;;=========================================================================;;;
