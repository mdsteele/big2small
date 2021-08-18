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
INCLUDE "src/macros.inc"
INCLUDE "src/worldmap.inc"

;;;=========================================================================;;;

POBJ_SOUTH EQU 0
POBJ_NORTH EQU 1
POBJ_WEST EQU 2
POBJ_EAST EQU (POBJ_WEST | POBJF_FLIP)
POBJ_SPACESHIP EQU 3
POBJ_INVIS EQU 5

;;;=========================================================================;;;

;;; Emits a PSFX path opcode.
;;;
;;; Example:
;;;     PATH_PSFX PSFX_JUMP  ; Plays the "jump" sound effect.
PATH_PSFX: MACRO
    STATIC_ASSERT _NARG == 1
    DB %11100000 | (\1)
ENDM

;;; Emits a SETJ path opcode.
;;;
;;; Example:
;;;     PATH_SETJ 2  ; Sets the current jump height to 2.
PATH_SETJ: MACRO
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

;;; Emits a REPT path opcode.
;;;
;;; Example:
;;;     PATH_REPT 2  ; Repeats previous speed for 2 more frames.
PATH_REPT: MACRO
    STATIC_ASSERT _NARG == 1
    ASSERT (\1) > 0
    ASSERT (\1) < 64
    DB (\1)
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
    PATH_REPT (\3) - 1
    ENDC
ENDM

;;; Emits path opcodes to jump with a given ground speed, taking 10 steps at
;;; that speed while staying airborne for 30 frames.
;;;
;;; Example:
;;;     PATH_JUMP -1, 1  ; Jumps with ground speed x=-1 y=1.
PATH_JUMP: MACRO
    STATIC_ASSERT _NARG == 2
    IF (\1) >= 0
GND_X0 = ((0 + (\1)) / 3)
GND_X1 = ((2 + (\1)) / 3)
GND_X2 = ((1 + (\1)) / 3)
    ELSE
GND_X0 = -((0 - (\1)) / 3)
GND_X1 = -((2 - (\1)) / 3)
GND_X2 = -((1 - (\1)) / 3)
    ENDC
    IF (\2) >= 0
GND_Y0 = ((0 + (\2)) / 3)
GND_Y1 = ((2 + (\2)) / 3)
GND_Y2 = ((1 + (\2)) / 3)
    ELSE
GND_Y0 = -((0 - (\2)) / 3)
GND_Y1 = -((2 - (\2)) / 3)
GND_Y2 = -((1 - (\2)) / 3)
    ENDC
    ;; Up:
    PATH_SETJ 2
    PATH_STEP GND_X0, GND_Y0
    PATH_SETJ 4
    PATH_STEP GND_X1, GND_Y1
    PATH_SETJ 6
    PATH_STEP GND_X2, GND_Y2
    PATH_SETJ 8
    PATH_STEP GND_X0, GND_Y0
    PATH_SETJ 10
    PATH_STEP GND_X1, GND_Y1
    PATH_SETJ 12
    PATH_STEP GND_X2, GND_Y2
    PATH_SETJ 13
    PATH_STEP GND_X0, GND_Y0
    PATH_SETJ 14
    PATH_STEP GND_X1, GND_Y1
    PATH_SETJ 15
    PATH_STEP GND_X2, GND_Y2
    PATH_SETJ 16
    PATH_STEP GND_X0, GND_Y0
    PATH_SETJ 17
    PATH_STEP GND_X1, GND_Y1
    PATH_SETJ 18
    PATH_STEP GND_X2, GND_Y2
    PATH_STEP GND_X0, GND_Y0
    PATH_STEP GND_X1, GND_Y1
    PATH_STEP GND_X2, GND_Y2
    ;; Down:
    PATH_STEP GND_X0, GND_Y0
    PATH_STEP GND_X1, GND_Y1
    PATH_STEP GND_X2, GND_Y2
    PATH_SETJ 17
    PATH_STEP GND_X0, GND_Y0
    PATH_SETJ 16
    PATH_STEP GND_X1, GND_Y1
    PATH_SETJ 15
    PATH_STEP GND_X2, GND_Y2
    PATH_SETJ 14
    PATH_STEP GND_X0, GND_Y0
    PATH_SETJ 13
    PATH_STEP GND_X1, GND_Y1
    PATH_SETJ 12
    PATH_STEP GND_X2, GND_Y2
    PATH_SETJ 10
    PATH_STEP GND_X0, GND_Y0
    PATH_SETJ 8
    PATH_STEP GND_X1, GND_Y1
    PATH_SETJ 6
    PATH_STEP GND_X2, GND_Y2
    PATH_SETJ 4
    PATH_STEP GND_X0, GND_Y0
    PATH_SETJ 2
    PATH_STEP GND_X1, GND_Y1
    PATH_SETJ 0
    PATH_STEP GND_X2, GND_Y2
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
    ld a, c
    mult sizeof_LOCA
    ldb bc, a
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
    DB 213, 30     ; X, Y
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
    PATH_JUMP 0, 0
    PATH_PSFX PSFX_JUMP
    PATH_JUMP 0, 0
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
    PATH_JUMP -2, 1
    PATH_WALK -1, 0, 5
    PATH_PSFX PSFX_JUMP
    PATH_JUMP -2, 1
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
    PATH_JUMP 1, 1
    PATH_WALK 0, 1, 6
    PATH_PSFX PSFX_JUMP
    PATH_JUMP 1, 1
    PATH_WALK 0, 1, 46
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
    PATH_WALK 0, -2, 39
    PATH_WALK 0, -1, 12
    PATH_WALK 0, 0, 4
    PATH_POBJ POBJ_EAST
    PATH_WALK 1, 0, 15
    PATH_POBJ POBJ_SOUTH
    PATH_HALT

DataX_LocationData_SpaceToCity_path:
    PATH_POBJ POBJ_WEST
    PATH_WALK -1, 0, 15
    PATH_PSFX PSFX_LAUNCH
    PATH_POBJ POBJ_SPACESHIP
    PATH_WALK 0, 1, 12
    PATH_WALK 0, 2, 39
    PATH_WALK 0, 1, 12
    PATH_WALK 0, 0, 12
    PATH_POBJ POBJ_SOUTH
    PATH_HALT

;;;=========================================================================;;;
