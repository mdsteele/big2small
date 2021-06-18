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

;;; Bit indices for specifying flags in a PBOJ path opcode.
POBJB_FLIP  EQU 4
POBJB_UNDER EQU 5

;;; Flags for a POBJ path opcode.
POBJF_FLIP  EQU (1 << POBJB_FLIP)
POBJF_UNDER EQU (1 << POBJB_UNDER)

RSRESET
;;; Enum values to use in PSFX path opcodes.
PSFX_JUMP   RB 1
PSFX_LAUNCH RB 1
;;; The number of path sound effects.
NUM_PSFXS   RB 0

;;;=========================================================================;;;

;;; LOCA: Describes a location on the world map.
RSRESET
;;; PixelX: The pixel X coordinate on the 256x256 world tile map for this
;;;   location.
LOCA_PixelX_u8         RB 1
;;; PixelY: The pixel Y coordinate on the 256x256 world tile map for this
;;;   location.
LOCA_PixelY_u8         RB 1
;;; PrevDir: The direction to press on the D-pad (one of the PADF_* values) to
;;;   go to the previous location, or zero if there is no previous location.
LOCA_PrevDir_u8        RB 1
;;; NextDir: The direction to press on the D-pad (one of the PADF_* values) to
;;;   go to the next location, or zero if there is no next location.
LOCA_NextDir_u8        RB 1
;;; PrevPath: Points to the PATH struct to use when moving to the previous
;;;   location.
LOCA_PrevPath_path_ptr RW 1
;;; NextPath: Points to the PATH struct to use when moving to the next
;;;   location.
LOCA_NextPath_path_ptr RW 1
sizeof_LOCA RB 0

;;;=========================================================================;;;

;;; PATH: Describes a path between locations on the world map.
RSRESET
;;; Opcodes: The start of an array of one or more path opcode bytes.  The
;;;   opcode decoding scheme is as follows:
;;;     - PSFX [%11ssssss].  Plays a sound effect.  The %ssssss should be one
;;;       of the PSFX_* values above.
;;;     - POBJ [%10uftttt].  Sets the avatar object.  The tile ID of the object
;;;       will be set based on %tttt.  The object will be flipped horizontally
;;;       if %f=1.  It will be under the background if %u=1.
;;;     - STEP [%01xxxyyy].  Sets the avatar's horzizontal speed to %xxx and
;;;       vertical speed to %yyy (each signed), and walks at that speed for one
;;;       frame.
;;;     - REPT [%00dddddd].  Walks at the most recently set speed for %dddddd
;;;       more frames.
;;;     - HALT [%00000000].  Marks the end of the path.
PATH_Opcodes_u8_arr RB 0

;;;=========================================================================;;;
