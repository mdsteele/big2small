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
INCLUDE "src/hardware.inc"
INCLUDE "src/worldmap.inc"

;;;=========================================================================;;;

POBJ_SOUTH EQU 0
POBJ_NORTH EQU 1
POBJ_WEST EQU 2
POBJ_EAST EQU (POBJ_WEST | POBJF_FLIP)
POBJ_SPACESHIP EQU 3
POBJ_INVIS EQU 4

;;;=========================================================================;;;

;;; Emits a PSFX path opcode.
;;;
;;; Example:
;;;     PATH_PSFX PSFX_JUMP  ; Plays the "jump" sound effect.
PATH_PSFX: MACRO
    STATIC_ASSERT _NARG == 1
    DB %11000000 | (\1)
ENDM

;;; Emits a POBJ path opcode.
;;;
;;; Example:
;;;     PATH_POBJ POBJ_EAST | POBJF_UNDER  ; Makes avatar face east, under BG.
PATH_POBJ: MACRO
    STATIC_ASSERT _NARG == 1
    DB %10000000 | (\1)
ENDM

;;; Emits a STEP path opcode with the given (x, y) values.
;;;
;;; Example:
;;;     PATH_STEP 2, -1  ; Walks at speed x=2 y=-1 for one frame.
PATH_STEP: MACRO
    STATIC_ASSERT _NARG == 2
    STATIC_ASSERT -3 <= (\1) && (\1) <= 3
    STATIC_ASSERT -3 <= (\2) && (\2) <= 3
    DB %01000000 | (((\1) & %00000111) << 3) | ((\2) & %00000111)
ENDM

;;; Emits path opcodes to walk at a given speed for a given number of frames.
;;;
;;; Example:
;;;     PATH_WALK 2, -1, 8  ; Walks at speed x=2 y=-1 for eight frames.
PATH_WALK: MACRO
    STATIC_ASSERT _NARG == 3
    STATIC_ASSERT (\3) >= 1
    STATIC_ASSERT (\3) <= 64
    PATH_STEP (\1), (\2)
    IF (\3) > 1
    DB (\3) - 1
    ENDC
ENDM

;;; Emits path opcodes to jump with a given ground speed, staying airborne for
;;; a given number of frames.
;;;
;;; Example:
;;;     PATH_JUMP -1, 1, 30  ; Jumps with ground speed x=-1 y=1 for 30 frames.
PATH_JUMP: MACRO
    STATIC_ASSERT _NARG == 3
    STATIC_ASSERT (\3) >= 1
    STATIC_ASSERT (\3) % 2 == 0
JUMP_D = 6  ; Smaller number means higher jumps
JUMP_H = ((\3) / 2)
JUMP_N = 0
    REPT JUMP_H
    IF JUMP_N % 3 == 1
    PATH_STEP (\1), (\2) - (JUMP_H / JUMP_D - JUMP_N / JUMP_D)
    ELSE
    PATH_STEP 0, -(JUMP_H / JUMP_D - JUMP_N / JUMP_D)
    ENDC
JUMP_N = (JUMP_N + 1)
    ENDR
JUMP_N = (JUMP_H - 1)
    REPT JUMP_H
    IF JUMP_N % 3 == 1
    PATH_STEP (\1), (\2) + (JUMP_H / JUMP_D - JUMP_N / JUMP_D)
    ELSE
    PATH_STEP 0, (JUMP_H / JUMP_D - JUMP_N / JUMP_D)
    ENDC
JUMP_N = (JUMP_N - 1)
    ENDR
ENDM

;;; Emits a HALT path opcode to mark the end of the path.
;;;
;;; Example:
;;;     PATH_HALT
PATH_HALT: MACRO
    STATIC_ASSERT _NARG == 0
    DB 0
ENDM

;;;=========================================================================;;;

SECTION "LocationData", ROMX

;;; Returns a pointer to the specified LOCA struct in BANK("LocationData").
;;; @param c The area number (one of the AREA_* enum values).
;;; @return hl A pointer to the specified LOCA struct.
;;; @preserve de
FuncX_LocationData_Get_hl::
    ASSERT sizeof_LOCA == 8
    swap c
    srl c
    ld b, 0
    ld hl, DataX_LocationData_loca_arr
    add hl, bc
    ret

DataX_LocationData_loca_arr:
    .begin
    ASSERT @ - .begin == sizeof_LOCA * AREA_FOREST
    DB 72, 209     ; X, Y
    DB 0           ; prev dir
    DB PADF_UP     ; next dir
    DW DataX_LocationData_Null_path
    DW DataX_LocationData_ForestToFarm_path
    ASSERT @ - .begin == sizeof_LOCA * AREA_FARM
    DB 59, 148     ; X, Y
    DB PADF_DOWN   ; prev dir
    DB PADF_RIGHT  ; next dir
    DW DataX_LocationData_FarmToForest_path
    DW DataX_LocationData_FarmToMountain_path
    ASSERT @ - .begin == sizeof_LOCA * AREA_MOUNTAIN
    DB 130, 108    ; X, Y
    DB PADF_LEFT   ; prev dir
    DB PADF_DOWN   ; next dir
    DW DataX_LocationData_MountainToFarm_path
    DW DataX_LocationData_MountainToLake_path
    ASSERT @ - .begin == sizeof_LOCA * AREA_LAKE
    DB 150, 183    ; X, Y
    DB PADF_UP     ; prev dir
    DB PADF_RIGHT  ; next dir
    DW DataX_LocationData_LakeToMountain_path
    DW DataX_LocationData_LakeToSewer_path
    ASSERT @ - .begin == sizeof_LOCA * AREA_SEWER
    DB 202, 215    ; X, Y
    DB PADF_LEFT   ; prev dir
    DB PADF_UP     ; next dir
    DW DataX_LocationData_SewerToLake_path
    DW DataX_LocationData_SewerToCity_path
    ASSERT @ - .begin == sizeof_LOCA * AREA_CITY
    DB 198, 132    ; X, Y
    DB PADF_DOWN   ; prev dir
    DB PADF_UP     ; next dir
    DW DataX_LocationData_CityToSewer_path
    DW DataX_LocationData_CityToSpace_path
    ASSERT @ - .begin == sizeof_LOCA * AREA_SPACE
    DB 198, 32     ; X, Y
    DB PADF_DOWN   ; prev dir
    DB 0           ; next dir
    DW DataX_LocationData_SpaceToCity_path
    DW DataX_LocationData_Null_path
    ASSERT @ - .begin == sizeof_LOCA * NUM_AREAS

DataX_LocationData_Null_path:
    PATH_HALT

DataX_LocationData_NewGame_path::
    PATH_POBJ POBJ_SOUTH
    PATH_WALK 0, 0, 20
    PATH_PSFX PSFX_JUMP
    PATH_JUMP 0, 0, 30
    PATH_PSFX PSFX_JUMP
    PATH_JUMP 0, 0, 30
    PATH_WALK 0, 0, 20
    PATH_POBJ POBJ_EAST
    PATH_WALK 1, 0, 4
    PATH_POBJ POBJ_NORTH
    PATH_WALK 0, -1, 4
    PATH_POBJ POBJ_NORTH | POBJF_UNDER
    PATH_WALK 0, -1, 18
    PATH_POBJ POBJ_EAST | POBJF_UNDER
    PATH_WALK 1, 0, 8
    PATH_POBJ POBJ_EAST
    PATH_WALK 1, 0, 8
    PATH_POBJ POBJ_SOUTH
    PATH_HALT

DataX_LocationData_ForestToFarm_path:
    PATH_POBJ POBJ_NORTH
    PATH_WALK 0, -1, 4
    PATH_POBJ POBJ_NORTH | POBJF_UNDER
    PATH_WALK 0, -1, 28
    PATH_POBJ POBJ_NORTH
    PATH_WALK -1, -1, 13
    PATH_WALK 0, -1, 16
    PATH_POBJ POBJ_SOUTH
    PATH_HALT

DataX_LocationData_FarmToForest_path:
    PATH_POBJ POBJ_SOUTH
    PATH_WALK 0, 1, 16
    PATH_WALK 1, 1, 13
    PATH_POBJ POBJ_SOUTH | POBJF_UNDER
    PATH_WALK 0, 1, 28
    PATH_POBJ POBJ_SOUTH
    PATH_WALK 0, 1, 4
    PATH_HALT

DataX_LocationData_FarmToMountain_path:
    PATH_POBJ POBJ_SOUTH
    PATH_WALK 1, 1, 3
    PATH_POBJ POBJ_EAST
    PATH_WALK 1, 1, 3
    PATH_WALK 1, 0, 29
    PATH_WALK 1, -1, 3
    PATH_POBJ POBJ_NORTH
    PATH_WALK 1, -1, 3
    PATH_WALK 0, -1, 28
    PATH_POBJ POBJ_EAST
    PATH_WALK 1, 0, 8
    PATH_POBJ POBJ_NORTH
    PATH_WALK 0, -1, 16
    PATH_POBJ POBJ_EAST
    PATH_WALK 1, 0, 22
    PATH_POBJ POBJ_SOUTH
    PATH_WALK 0, 1, 4
    PATH_HALT

DataX_LocationData_MountainToFarm_path:
    PATH_POBJ POBJ_WEST
    PATH_WALK -1, 0, 3
    PATH_PSFX PSFX_JUMP
    PATH_JUMP -2, 1, 30
    PATH_WALK -1, 0, 5
    PATH_PSFX PSFX_JUMP
    PATH_JUMP -2, 1, 30
    PATH_POBJ POBJ_SOUTH
    PATH_WALK 0, 1, 26
    PATH_POBJ POBJ_WEST
    PATH_WALK -1, 0, 17
    PATH_WALK -1, -1, 3
    PATH_POBJ POBJ_NORTH
    PATH_WALK -1, -1, 3
    PATH_POBJ POBJ_SOUTH
    PATH_HALT

DataX_LocationData_MountainToLake_path:
    PATH_POBJ POBJ_SOUTH
    PATH_WALK 0, 1, 4
    PATH_PSFX PSFX_JUMP
    PATH_JUMP 1, 1, 30
    PATH_WALK 0, 1, 8
    PATH_PSFX PSFX_JUMP
    PATH_JUMP 1, 1, 30
    PATH_WALK 0, 1, 44
    PATH_HALT

DataX_LocationData_LakeToMountain_path:
    PATH_POBJ POBJ_NORTH
    PATH_WALK 1, -1, 4
    PATH_WALK 0, -1, 24
    PATH_WALK -1, -1, 7
    PATH_WALK 0, -1, 21
    PATH_POBJ POBJ_WEST
    PATH_WALK -1, 0, 8
    PATH_POBJ POBJ_NORTH
    PATH_WALK 0, -1, 19
    PATH_POBJ POBJ_WEST
    PATH_WALK -1, 0, 9
    PATH_POBJ POBJ_SOUTH
    PATH_HALT

DataX_LocationData_LakeToSewer_path:
    PATH_POBJ POBJ_EAST
    PATH_WALK 1, 0, 18
    PATH_WALK 1, 1, 6
    PATH_POBJ POBJ_SOUTH
    PATH_WALK 1, 1, 6
    PATH_WALK 0, 1, 22
    PATH_WALK 1, 1, 2
    PATH_POBJ POBJ_EAST
    PATH_WALK 1, 1, 2
    PATH_WALK 1, 0, 12
    PATH_WALK 1, -1, 6
    PATH_POBJ POBJ_SOUTH
    PATH_HALT

DataX_LocationData_SewerToLake_path:
    PATH_POBJ POBJ_SOUTH
    PATH_WALK -1, 1, 3
    PATH_POBJ POBJ_WEST
    PATH_WALK -1, 1, 3
    PATH_WALK -1, 0, 12
    PATH_WALK -1, -1, 2
    PATH_POBJ POBJ_NORTH
    PATH_WALK -1, -1, 2
    PATH_WALK 0, -1, 22
    PATH_WALK -1, -1, 6
    PATH_POBJ POBJ_WEST
    PATH_WALK -1, -1, 6
    PATH_WALK -1, 0, 18
    PATH_POBJ POBJ_SOUTH
    PATH_HALT

DataX_LocationData_SewerToCity_path:
    PATH_POBJ POBJ_NORTH
    PATH_WALK 0, -1, 6
    PATH_PSFX PSFX_PIPE
    PATH_POBJ POBJ_INVIS
    PATH_WALK 0, -2, 13
    PATH_WALK -2, 0, 4
    PATH_WALK 0, -1, 16
    PATH_WALK -2, 0, 4
    PATH_WALK 0, -1, 8
    PATH_WALK -1, 0, 24
    PATH_WALK 0, -1, 24
    PATH_WALK 1, 0, 6
    PATH_POBJ POBJ_EAST
    PATH_WALK 1, 0, 8
    PATH_POBJ POBJ_SOUTH
    PATH_WALK 0, 1, 8
    PATH_POBJ POBJ_EAST
    PATH_WALK 1, 0, 22
    PATH_POBJ POBJ_NORTH
    PATH_WALK 0, -1, 11
    PATH_POBJ POBJ_SOUTH
    PATH_HALT

DataX_LocationData_CityToSewer_path:
    PATH_POBJ POBJ_SOUTH
    PATH_WALK 0, 1, 11
    PATH_POBJ POBJ_WEST
    PATH_WALK -1, 0, 22
    PATH_POBJ POBJ_NORTH
    PATH_WALK 0, -1, 8
    PATH_POBJ POBJ_WEST
    PATH_WALK -1, 0, 8
    PATH_PSFX PSFX_PIPE
    PATH_POBJ POBJ_INVIS
    PATH_WALK -1, 0, 6
    PATH_WALK 0, 1, 24
    PATH_WALK 1, 0, 24
    PATH_WALK 0, 1, 8
    PATH_WALK 2, 0, 4
    PATH_WALK 0, 1, 16
    PATH_WALK 2, 0, 4
    PATH_WALK 0, 2, 13
    PATH_POBJ POBJ_SOUTH
    PATH_WALK 0, 1, 6
    PATH_HALT

DataX_LocationData_CityToSpace_path:
    PATH_PSFX PSFX_LAUNCH
    PATH_POBJ POBJ_SPACESHIP
    PATH_WALK 0, -1, 12
    PATH_WALK 0, -2, 44
    PATH_POBJ POBJ_SOUTH
    PATH_HALT

DataX_LocationData_SpaceToCity_path:
    PATH_PSFX PSFX_LAUNCH
    PATH_POBJ POBJ_SPACESHIP
    PATH_WALK 0, 2, 44
    PATH_WALK 0, 1, 12
    PATH_POBJ POBJ_SOUTH
    PATH_HALT

;;;=========================================================================;;;
