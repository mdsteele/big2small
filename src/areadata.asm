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

INCLUDE "src/areamap.inc"
INCLUDE "src/charmap.inc"
INCLUDE "src/color.inc"
INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"
INCLUDE "src/primitive.inc"
INCLUDE "src/save.inc"
INCLUDE "src/tileset.inc"

;;;=========================================================================;;;

;;; Declares a 3-byte banked pointer to the given label.
;;;
;;; Example:
;;;     D_BPTR DataX_Foo
MACRO D_BPTR
    STATIC_ASSERT _NARG == 1
    DB BANK(\1), LOW(\1), HIGH(\1)
ENDM

;;; Declares a title string for an AREA or NODE struct.  The first argument
;;; gives the size of the field in bytes, and the second argument gives the
;;; title string (which will be centered with spaces within the field).
;;;
;;; Example:
;;;     D_TITLE 16, "Foo Bar"
MACRO D_TITLE
    ASSERT _NARG == 2
    ASSERT STRLEN(\2) <= (\1)
    DS ((\1) - STRLEN(\2)) / 2, " "
    DB \2
    DS (1 + (\1) - STRLEN(\2)) / 2, " "
ENDM

;;;=========================================================================;;;

;;; Constants for D_TRAIL arguments:
TE1 EQU (TRAIL_EAST  | 1)
TE2 EQU (TRAIL_EAST  | 2)
TE4 EQU (TRAIL_EAST  | 4)
TN1 EQU (TRAIL_NORTH | 1)
TN2 EQU (TRAIL_NORTH | 2)
TS1 EQU (TRAIL_SOUTH | 1)
TS2 EQU (TRAIL_SOUTH | 2)
TW1 EQU (TRAIL_WEST  | 1)
TW2 EQU (TRAIL_WEST  | 2)
UE2 EQU (TRAIL_EAST  | 2 | TRAILF_UNDER)
UE3 EQU (TRAIL_EAST  | 3 | TRAILF_UNDER)
UN2 EQU (TRAIL_NORTH | 2 | TRAILF_UNDER)
US1 EQU (TRAIL_SOUTH | 1 | TRAILF_UNDER)
UW3 EQU (TRAIL_WEST  | 3 | TRAILF_UNDER)

;;; Declares a Trail/ExitTrail field within a NODE/AREA struct.  There should
;;; be 1 to MAX_TRAIL_LENGTH arguments (inclusive), with each being one of the
;;; above T?? or U?? constants.  The last entry will automatically be marked
;;; with TRAILB_END, and the field will automatically be padded to
;;; MAX_TRAIL_LENGTH bytes.
;;;
;;; Example:
;;;     D_TRAIL TS1, TS1, TS1, TE1, TE2, TE1
MACRO D_TRAIL
_TRAIL_LENGTH = _NARG
    ASSERT _TRAIL_LENGTH >= 1 && _TRAIL_LENGTH <= MAX_TRAIL_LENGTH
    REPT _TRAIL_LENGTH - 1
    DB \1
    SHIFT
    ENDR
    DB (\1) | (1 << TRAILB_END)
    DS MAX_TRAIL_LENGTH - _TRAIL_LENGTH
ENDM

;;;=========================================================================;;;

SECTION "AreaFunctions", ROM0

;;; Returns the area that a given puzzle is in.
;;; @param c The puzzle number.
;;; @return c The AREA_* enum value for the area that the puzzle is in.
Func_GetPuzzleArea_c::
    ld a, c
    if_ge FIRST_LAKE_PUZZLE, jr, .lakeOrGreater
    if_ge FIRST_FARM_PUZZLE, jr, .farmOrMountain
    ld c, AREA_FOREST
    ret
    .farmOrMountain
    if_ge FIRST_MOUNTAIN_PUZZLE, jr, .mountain
    ld c, AREA_FARM
    ret
    .mountain
    ld c, AREA_MOUNTAIN
    ret
    .lakeOrGreater
    if_ge FIRST_CITY_PUZZLE, jr, .cityOrGreater
    if_ge FIRST_SEWER_PUZZLE, jr, .sewer
    ld c, AREA_LAKE
    ret
    .sewer
    ld c, AREA_SEWER
    ret
    .cityOrGreater
    if_ge FIRST_SPACE_PUZZLE, jr, .space
    ld c, AREA_CITY
    ret
    .space
    ld c, AREA_SPACE
    ret

;;;=========================================================================;;;

SECTION "AreaData", ROMX

;;; Returns a pointer to the specified AREA struct in BANK("AreaData").
;;; @param c The area number (one of the AREA_* enum values).
;;; @return hl A pointer to the specified AREA struct.
;;; @preserve de
FuncX_AreaData_Get_hl::
    sla c
    ld b, 0
    ld hl, DataX_AreaData_Table_area_ptr_arr
    add hl, bc
    deref hl
    ret

;;; An array that maps from AREA_* enum values to pointers to AREA structs
;;; stored in BANK("AreaData").
DataX_AreaData_Table_area_ptr_arr:
    .begin
    ASSERT @ - .begin == sizeof_PTR * AREA_FOREST
    DW DataX_AreaData_Forest_area
    ASSERT @ - .begin == sizeof_PTR * AREA_FARM
    DW DataX_AreaData_Farm_area
    ASSERT @ - .begin == sizeof_PTR * AREA_MOUNTAIN
    DW DataX_AreaData_Mountain_area
    ASSERT @ - .begin == sizeof_PTR * AREA_LAKE
    DW DataX_AreaData_Lake_area
    ASSERT @ - .begin == sizeof_PTR * AREA_SEWER
    DW DataX_AreaData_Sewer_area
    ASSERT @ - .begin == sizeof_PTR * AREA_CITY
    DW DataX_AreaData_City_area
    ASSERT @ - .begin == sizeof_PTR * AREA_SPACE
    DW DataX_AreaData_Space_area

DataX_AreaData_Forest_area:
    .begin
    D_BPTR DataX_ForestMap_song
    DB COLORSET_SUMMER
    DB TILESET_MAP_FOREST
    D_BPTR DataX_ForestTileMap_start
    D_TITLE 20, "GIANT'S FOREST"
    D_TRAIL TN1, TN1, TN1
    DB FIRST_FOREST_PUZZLE
    DB NUM_FOREST_PUZZLES
    ASSERT @ - .begin == AREA_Nodes_node_arr
_AreaData_Forest_Node0:
    .begin
    DB 9, 3  ; row/col
    D_TRAIL TW1, TW1, TW1, TW1
    DB PADF_LEFT | EXIT_MAP    ; prev
    DB PADF_DOWN | 1           ; next
    DB 0                       ; bonus
    D_TITLE 16, "Peanut Pathway"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Forest_Node1:
    .begin
    DB 13, 7  ; row/col
    D_TRAIL TW1, TW1, TW1, TW1, TN1, TN1, TN1, TN1
    DB PADF_LEFT | 0           ; prev
    DB PADF_RIGHT | 2          ; next
    DB 0                       ; bonus
    D_TITLE 16, "Goat Grove"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Forest_Node2:
    .begin
    DB 13, 13  ; row/col
    D_TRAIL TW1, UW3, TW1, TW1
    DB PADF_LEFT | 1           ; prev
    DB PADF_RIGHT | 3          ; next
    DB 0                       ; bonus
    D_TITLE 16, "Trio Thicket"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Forest_Node3:
    .begin
    DB 11, 17  ; row/col
    D_TRAIL TW1, TW1, TS1, TS1, TW1, TW1
    DB PADF_LEFT | 2           ; prev
    DB PADF_UP | 4             ; next
    DB 0                       ; bonus
    D_TITLE 16, "Winding Woods"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Forest_Node4:
    .begin
    DB 6, 14  ; row/col
    D_TRAIL TE1, TE1, TE1, TS1, TS1, TS1, TS1, TS1
    DB PADF_RIGHT | 3          ; prev
    DB PADF_LEFT | 6           ; next
    DB 0                       ; bonus
    D_TITLE 16, "Shrubbery Snag"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Forest_Node5:
    .begin
    DB 4, 1  ; row/col
    D_TRAIL TE1, UE3, TE1, TE1, TE1, TE1
    DB PADF_RIGHT | 6          ; prev
    DB 0                       ; next
    DB 0                       ; bonus
    D_TITLE 16, "Baffling Bushes"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Forest_Node6:
    .begin
    DB 4, 9  ; row/col
    D_TRAIL TS1, TS1, TS1, TS1, TE1, TE1, TE1, TN1, TN1, TE1, TE1
    DB PADF_DOWN | 4           ; prev
    DB PADF_UP | EXIT_MAP      ; next
    DB PADF_LEFT | 5           ; bonus
    D_TITLE 16, "Obstacle Orchard"
    ASSERT @ - .begin == sizeof_NODE
ASSERT @ - _AreaData_Forest_Node0 == NUM_FOREST_PUZZLES * sizeof_NODE

DataX_AreaData_Farm_area:
    .begin
    D_BPTR DataX_Circus_song
    DB COLORSET_SUMMER
    DB TILESET_MAP_FOREST
    D_BPTR DataX_FarmTileMap_start
    D_TITLE 20, "HUGESON FARMS"
    D_TRAIL TE1, TE1, TE1, TE1
    DB FIRST_FARM_PUZZLE
    DB NUM_FARM_PUZZLES
    ASSERT @ - .begin == AREA_Nodes_node_arr
_AreaData_Farm_Node0:
    .begin
    DB 11, 5  ; row/col
    D_TRAIL TS1, TS1, TS1, TS1, US1
    DB PADF_DOWN | EXIT_MAP    ; prev
    DB PADF_UP | 1             ; next
    DB 0                       ; bonus
    D_TITLE 16, "Out to Pasture"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Farm_Node1:
    .begin
    DB 5, 10  ; row/col
    D_TRAIL TW1, TW1, TS1, TS1, TW1, TW1, TW1, TS1, TS1, TS1, TS1
    DB PADF_LEFT | 0           ; prev
    DB PADF_RIGHT | 2          ; next
    DB 0                       ; bonus
    D_TITLE 16, "On The Fence"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Farm_Node2:
    .begin
    DB 8, 15  ; row/col
    D_TRAIL TE1, TN1, TN1, TN1, TW1, TW1, TW1, TW1, TW1, TW1
    DB PADF_RIGHT | 1          ; prev
    DB PADF_DOWN | 4           ; next
    DB 0                       ; bonus
    D_TITLE 16, "Plow Ahead"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Farm_Node3:
    .begin
    DB 12, 11  ; row/col
    D_TRAIL TS1, TS1, TE1, TE1, TE1, TE1, TE1, TN1, TN1
    DB PADF_DOWN | 4           ; prev
    DB 0                       ; next
    DB 0                       ; bonus
    D_TITLE 16, "Don't Have a Cow"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Farm_Node4:
    .begin
    DB 12, 16  ; row/col
    D_TRAIL TW1, TN1, TN1, TN1, TN1
    DB PADF_LEFT | 2           ; prev
    DB PADF_RIGHT | EXIT_MAP   ; next
    DB PADF_DOWN | 3           ; bonus
    D_TITLE 16, "Barnyard Dance"
    ASSERT @ - .begin == sizeof_NODE
ASSERT @ - _AreaData_Farm_Node0 == NUM_FARM_PUZZLES * sizeof_NODE

DataX_AreaData_Mountain_area:
    .begin
    D_BPTR DataX_MountainMap_song
    DB COLORSET_SUMMER
    DB TILESET_MAP_FOREST
    D_BPTR DataX_MountainTileMap_start
    D_TITLE 20, "MT. BIGHORN"
    D_TRAIL TE1, TE1, TS1, TS2, TS1, US1
    DB FIRST_MOUNTAIN_PUZZLE
    DB NUM_MOUNTAIN_PUZZLES
    ASSERT @ - .begin == AREA_Nodes_node_arr
_AreaData_Mountain_Node0:
    .begin
    DB 14, 3  ; row/col
    D_TRAIL TW1, TW1, TW1, TW1
    DB PADF_LEFT | EXIT_MAP    ; prev
    DB PADF_UP | 1             ; next
    DB 0                       ; bonus
    D_TITLE 16, "Arrow Ascent"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Mountain_Node1:
    .begin
    DB 10, 5  ; row/col
    D_TRAIL TW1, TW1, TS1, TS2, TS1
    DB PADF_LEFT | 0           ; prev
    DB PADF_UP | 3             ; next
    DB PADF_RIGHT | 2          ; bonus
    D_TITLE 16, "Tranquil Trail"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Mountain_Node2:
    .begin
    DB 13, 8  ; row/col
    D_TRAIL TW1, TW1, TN1, TN1, TN1, TW1
    DB PADF_LEFT | 1           ; prev
    DB 0                       ; next
    DB 0                       ; bonus
    D_TITLE 16, "Hectic Hillside"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Mountain_Node3:
    .begin
    DB 4, 9  ; row/col
    D_TRAIL TW1, TW1, TW1, TW1, TS1, TS2, TS2, TS1
    DB PADF_LEFT | 1           ; prev
    DB PADF_DOWN | 5           ; next
    DB 0                       ; bonus
    D_TITLE 16, "Rocky Ridge"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Mountain_Node4:
    .begin
    DB 2, 15  ; row/col
    D_TRAIL TS1, TS2, TS2, TS1, TS2, TS1
    DB PADF_DOWN | 5           ; prev
    DB 0                       ; next
    DB 0                       ; bonus
    D_TITLE 16, "Starry Summit"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Mountain_Node5:
    .begin
    DB 11, 15  ; row/col
    D_TRAIL TW1, TW1, TN1, TN2, TW1, TW1, TW1, TW1, TN2, TN1, TN1
    DB PADF_LEFT | 3           ; prev
    DB PADF_RIGHT | EXIT_MAP   ; next
    DB PADF_UP | 4             ; bonus
    D_TITLE 16, "Grassy Grade"
    ASSERT @ - .begin == sizeof_NODE
ASSERT @ - _AreaData_Mountain_Node0 == NUM_MOUNTAIN_PUZZLES * sizeof_NODE

DataX_AreaData_Lake_area:
    .begin
    D_BPTR DataX_LakeMap_song
    DB COLORSET_SUMMER
    DB TILESET_MAP_FOREST
    D_BPTR DataX_LakeTileMap_start
    D_TITLE 20, "MIDDLING MARSH"
    D_TRAIL TN1, TE1, TE1, TE1, TE4, TE1, TE1
    DB FIRST_LAKE_PUZZLE
    DB NUM_LAKE_PUZZLES
    ASSERT @ - .begin == AREA_Nodes_node_arr
_AreaData_Lake_Node0:
    .begin
    DB 5, 12  ; row/col
    D_TRAIL TE1, TE2, TE1, TE1, TN1, TN1, TN1, TN1
    DB PADF_RIGHT | EXIT_MAP   ; prev
    DB PADF_LEFT | 1           ; next
    DB 0                       ; bonus
    D_TITLE 16, "Down the River"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Lake_Node1:
    .begin
    DB 6, 4  ; row/col
    D_TRAIL TE1, TE1, TN1, TE1, TE2, TE1, TE1, TE1
    DB PADF_RIGHT | 0          ; prev
    DB PADF_LEFT | 3           ; next
    DB PADF_UP | 2             ; bonus
    D_TITLE 16, "Up a Creek"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Lake_Node2:
    .begin
    DB 2, 1  ; row/col
    D_TRAIL TE1, TE2, TS1, TS1, TS1, TS1
    DB PADF_RIGHT | 1          ; prev
    DB 0                       ; next
    DB 0                       ; bonus
    D_TITLE 16, "Without a Paddle"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Lake_Node3:
    .begin
    DB 13, 2  ; row/col
    D_TRAIL TN1, TN1, TN2, TN1, TN1, TN1, TE1, TE1
    DB PADF_UP | 1             ; prev
    DB PADF_DOWN | 4           ; next
    DB 0                       ; bonus
    D_TITLE 16, "Around the Bend"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Lake_Node4:
    .begin
    DB 15, 11  ; row/col
    D_TRAIL TW1, TW1, TW1, TW1, TW2, TW1, TW1, TW1, TN1, TN1
    DB PADF_LEFT | 3           ; prev
    DB PADF_UP | EXIT_MAP      ; next
    DB 0                       ; bonus
    D_TITLE 16, "Across the Pond"
    ASSERT @ - .begin == sizeof_NODE
ASSERT @ - _AreaData_Lake_Node0 == NUM_LAKE_PUZZLES * sizeof_NODE

DataX_AreaData_Sewer_area:
    .begin
    D_BPTR DataX_SewerMap_song
    DB COLORSET_SEWER
    DB TILESET_MAP_SEWER
    D_BPTR DataX_SewerTileMap_start
    D_TITLE 20, "DEMI SEWERS"
    D_TRAIL TN1, UN2, TN1
    DB FIRST_SEWER_PUZZLE
    DB NUM_SEWER_PUZZLES
    ASSERT @ - .begin == AREA_Nodes_node_arr
_AreaData_Sewer_Node0:
    .begin
    DB 13, 5  ; row/col
    D_TRAIL TN1, TW1, TW1, TW1, TN1, TN1
    DB PADF_UP | EXIT_MAP      ; prev
    DB PADF_RIGHT | 1          ; next
    DB 0                       ; bonus
    D_TITLE 16, "Pipe Playground"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Sewer_Node1:
    .begin
    DB 13, 10  ; row/col
    D_TRAIL TW1, TW1, TW2, TW1
    DB PADF_LEFT | 0           ; prev
    DB PADF_RIGHT | 2          ; next
    DB 0                       ; bonus
    D_TITLE 16, "Blocked Drain"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Sewer_Node2:
    .begin
    DB 13, 16  ; row/col
    D_TRAIL TW1, TW1, TW2, TW1, TW1
    DB PADF_LEFT | 1           ; prev
    DB PADF_RIGHT | 3          ; next
    DB 0                       ; bonus
    D_TITLE 16, "Royal Flush"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Sewer_Node3:
    .begin
    DB 8, 17  ; row/col
    D_TRAIL TS1, TS1, TS1, TS1, TS1, TW1
    DB PADF_DOWN | 2           ; prev
    DB PADF_UP | 5             ; next
    DB 0                       ; bonus
    D_TITLE 16, "Mind the Gap"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Sewer_Node4:
    .begin
    DB 5, 5  ; row/col
    D_TRAIL TE1, UE2, TE1, TS1, TE1, TE1
    DB PADF_RIGHT | 5          ; prev
    DB 0                       ; next
    DB 0                       ; bonus
    D_TITLE 16, "Rodent-Rooter"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Sewer_Node5:
    .begin
    DB 6, 11  ; row/col
    D_TRAIL TE1, TE1, TS1, TE1, UE2, TE1, TS1
    DB PADF_RIGHT | 3          ; prev
    DB PADF_UP | EXIT_MAP      ; next
    DB PADF_LEFT | 4           ; bonus
    D_TITLE 16, "Combination Lock"
    ASSERT @ - .begin == sizeof_NODE
ASSERT @ - _AreaData_Sewer_Node0 == NUM_SEWER_PUZZLES * sizeof_NODE

DataX_AreaData_City_area:
    .begin
    D_BPTR DataX_CityMap_song
    DB COLORSET_CITY
    DB TILESET_MAP_CITY
    D_BPTR DataX_CityTileMap_start
    D_TITLE 20, "MICROVILLE"
    D_TRAIL TN1, TN2
    DB FIRST_CITY_PUZZLE
    DB NUM_CITY_PUZZLES
    ASSERT @ - .begin == AREA_Nodes_node_arr
_AreaData_City_Node0:
    .begin
    DB 12, 4  ; row/col
    D_TRAIL TW1, TW1, TW1
    DB PADF_LEFT | EXIT_MAP    ; prev
    DB PADF_DOWN | 1           ; next
    DB 0                       ; bonus
    D_TITLE 16, "Mousetrap Mayhem"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_City_Node1:
    .begin
    DB 15, 4  ; row/col
    D_TRAIL TN1, TN1, TN1
    DB PADF_UP | 0             ; prev
    DB PADF_RIGHT | 2          ; next
    DB 0                       ; bonus
    D_TITLE 16, "Traffic Terror"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_City_Node2:
    .begin
    DB 15, 12  ; row/col
    D_TRAIL TW1, TW1, TW1, TW1, TW1, TW1, TW1, TW1
    DB PADF_LEFT | 1           ; prev
    DB PADF_RIGHT | 4          ; next
    DB PADF_UP | 3             ; bonus
    D_TITLE 16, "Dumpster Diving"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_City_Node3:
    .begin
    DB 11, 12  ; row/col
    D_TRAIL TS1, TS1, TS1, TS1
    DB PADF_DOWN | 2           ; prev
    DB 0                       ; next
    DB 0                       ; bonus
    D_TITLE 16, "Back Lot Bedlam"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_City_Node4:
    .begin
    DB 15, 17  ; row/col
    D_TRAIL TW1, TW1, TW1, TW1, TW1
    DB PADF_LEFT | 2           ; prev
    DB PADF_UP | EXIT_MAP      ; next
    DB 0                       ; bonus
    D_TITLE 16, "Launch Pad Peril"
    ASSERT @ - .begin == sizeof_NODE
ASSERT @ - _AreaData_City_Node0 == NUM_CITY_PUZZLES * sizeof_NODE

DataX_AreaData_Space_area:
    .begin
    D_BPTR DataX_SpaceMap_song
    DB COLORSET_SPACE
    DB TILESET_MAP_SPACE
    D_BPTR DataX_SpaceTileMap_start
    D_TITLE 20, "NEUTRINO STATION"
    D_TRAIL TN1, TN1, TN1, TN1
    DB FIRST_SPACE_PUZZLE
    DB NUM_SPACE_PUZZLES
    ASSERT @ - .begin == AREA_Nodes_node_arr
_AreaData_Space_Node0:
    .begin
    DB 7, 5  ; row/col
    D_TRAIL TW1, TW1, TW1
    DB PADF_LEFT | EXIT_MAP    ; prev
    DB PADF_RIGHT | 1          ; next
    DB 0                       ; bonus
    D_TITLE 16, "Warp Speedway"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Space_Node1:
    .begin
    DB 7, 8  ; row/col
    D_TRAIL TW1, TW1, TW1
    DB PADF_LEFT | 0           ; prev
    DB PADF_RIGHT | 3          ; next
    DB PADF_DOWN | 2           ; bonus
    D_TITLE 16, "Vacuum Pressure"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Space_Node2:
    .begin
    DB 10, 8  ; row/col
    D_TRAIL TN1, TN1, TN1
    DB PADF_UP | 1             ; prev
    DB 0                       ; next
    DB 0                       ; bonus
    D_TITLE 16, "Hydroponics Lab"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Space_Node3:
    .begin
    DB 7, 12  ; row/col
    D_TRAIL TW1, TW1, TW1, TW1
    DB PADF_LEFT | 1           ; prev
    DB PADF_RIGHT | 5          ; next
    DB PADF_UP | 4             ; bonus
    D_TITLE 16, "Phase Relay"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Space_Node4:
    .begin
    DB 3, 12  ; row/col
    D_TRAIL TS1, TS1, TS1, TS1
    DB PADF_DOWN | 3           ; prev
    DB 0                       ; next
    DB 0                       ; bonus
    D_TITLE 16, "Navigation Array"
    ASSERT @ - .begin == sizeof_NODE
_AreaData_Space_Node5:
    .begin
    DB 8, 16  ; row/col
    D_TRAIL TW1, TW1, TN1, TW1, TW1
    DB PADF_LEFT | 3           ; prev
    DB PADF_UP | EXIT_CREDITS  ; next
    DB 0                       ; bonus
    D_TITLE 16, "Final Countdown"
    ASSERT @ - .begin == sizeof_NODE
ASSERT @ - _AreaData_Space_Node0 == NUM_SPACE_PUZZLES * sizeof_NODE

;;;=========================================================================;;;
