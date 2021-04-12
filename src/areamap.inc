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

RSRESET
;;; Enum values for Main_AreaMapScreen:
AREA_FOREST   RB 1
AREA_FARM     RB 1
AREA_MOUNTAIN RB 1
AREA_LAKE     RB 1
AREA_SEWER    RB 1
AREA_CITY     RB 1
AREA_SPACE    RB 1
;;; The number of areas in the game:
NUM_AREAS     RB 0

;;;=========================================================================;;;

;;; The maximum number of entries in a trail array in a NODE or AREA struct.
MAX_TRAIL_LENGTH EQU 11

;;; Direction constants for entries in NODE_Trail_u8_arr:
TRAIL_NORTH     EQU %00100000
TRAIL_SOUTH     EQU %00010000
TRAIL_EAST      EQU %00000000
TRAIL_WEST      EQU %00110000
;;; Mask for extracting the direction from a trail entry.  You can XOR a
;;; TRAIL_* value with this to produce the opposite direction.
TRAIL_DIR_MASK  EQU %00110000
;;; Mask for extracting the distance from a trail entry.
TRAIL_DIST_MASK EQU %00001111
;;; If this bit is set for a trail entry, then the avatar should be drawn
;;; underneath the map terrain while following this trail segment.
TRAILB_UNDER EQU 6
TRAILF_UNDER EQU (1 << TRAILB_UNDER)
;;; This bit is set for the last entry in NODE_Trail_u8_arr entry.
TRAILB_END EQU 7

;;; Special value used in place of a node index in NODE_Prev_u8 or NODE_Next_u8
;;; to indicate an exit from the area.
EXIT_NODE EQU $0f

;;;=========================================================================;;;

;;; AREA: Describes an "area" of the game; each area contains several puzzles.
RSRESET
;;; Music: A banked pointer to the SONG struct to play while on the area map
;;;   screen.
AREA_Music_song_bptr  RB 3
;;; Colorset: A COLORSET_* enum value indicating which set of background color
;;;   palettes to use on the area map screen.
AREA_Colorset_u8      RB 1
;;; Tileset: A TILESET_* enum value indicating which tileset this area's BG
;;;   tile map uses.
AREA_Tileset_u8       RB 1
;;; Music: A banked pointer to the BG tile map data for the area map screen.
AREA_TileMap_bptr     RB 3
;;; Title: A 20-character string containing the title of this area, padded with
;;;   spaces on either side so that the title is centered.
AREA_Title_u8_arr20   RB 20
;;; ExitTrail: An array of up to MAX_TRAIL_LENGTH entries describing the trail
;;;   of dots on the area map from the last node in the area to the area exit.
;;;   For each entry byte in the array, the TRAIL_DIR_MASK bits store the
;;;   direction towards the next dot (using one of the TRAIL_* constants), and
;;;   the TRAIL_DIST_MASK bits store the the distance to the next dot
;;;   (typically 1 or 2).  The last entry must have bit TRAILB_END set.
AREA_ExitTrail_u8_arr RB MAX_TRAIL_LENGTH
;;; FirstPuzzle: The puzzle number for node zero of this area.  Each node in
;;;   the area has a puzzle number equal to the node index plus this number.
AREA_FirstPuzzle_u8   RB 1
;;; NumNodes: The number of entries in this area's Nodes array (from 1 to 15
;;;   inclusive).
AREA_NumNodes_u8      RB 1
;;; Nodes: An array of NODE structs, one for each puzzle in this area.  The
;;;   Prev field of the first NODE in the array must connect to EXIT_NODE (for
;;;   the area entrance), and the Next field of the last NODE in the area must
;;;   also connect to EXIT_NODE (for the area exit).
AREA_Nodes_node_arr   RB 0

;;;=========================================================================;;;

;;; NODE: Describes a puzzle node within an area map.
RSRESET
;;; Row: The BG tile row on the area map for where this node is located (from
;;;   1 to 16 inclusive).
NODE_Row_u8         RB 1
;;; Col: The BG tile column on the area map for where this node is located
;;;   (from 0 to 19 inclusive).
NODE_Col_u8         RB 1
;;; Trail: An array of up to MAX_TRAIL_LENGTH entries describing the trail of
;;;   dots on the area map from this node back to the previous node.  For each
;;;   entry byte in the array, the TRAIL_DIR_MASK bits store the direction
;;;   towards the next dot (using one of the TRAIL_* constants), and the
;;;   TRAIL_DIST_MASK bits store the the distance to the next dot (typically 1
;;;   or 2).  The last entry must have bit TRAILB_END set.
NODE_Trail_u8_arr   RB MAX_TRAIL_LENGTH
;;; Prev: Describes how to reach the previous node.  The high nibble indicates
;;;   the direction to press on the D-pad (one of the PADF_* values).  The low
;;;   nibble gives the index of the previous node (from 0 to 14 inclusive), or
;;;   the special EXIT_NODE value if following this link should exit the area.
NODE_Prev_u8        RB 1
;;; Next: Describes how to reach the next node.  This is encoded exactly as
;;;   for the Prev field, except that the whole field may be zero if there is
;;;   no next node.
NODE_Next_u8        RB 1
;;; Bonus: Describes how to reach this node's bonus node, if any.  This is
;;;   encoded exactly as for the Next field, except that the special EXIT_NODE
;;;   value may not be used for the node index.
NODE_Bonus_u8       RB 1
;;; Title: An 16-character string containing the puzzle title, padded with
;;;   spaces on either side so that the title is centered.
NODE_Title_u8_arr16 RB 16
sizeof_NODE         RB 0

;;;=========================================================================;;;
