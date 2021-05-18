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
INCLUDE "src/macros.inc"
INCLUDE "src/puzzle.inc"

;;;=========================================================================;;;

ARROW_PALETTE    EQU (OAMF_PAL1 | 0)
ELEPHANT_PALETTE EQU (OAMF_PAL0 | 1)
GOAT_PALETTE     EQU (OAMF_PAL1 | 2)
MOUSE_PALETTE    EQU (OAMF_PAL0 | 3)
SMOKE_PALETTE    EQU (OAMF_PAL0 | 4)
PIPE_PALETTE     EQU (OAMF_PAL0 | 7)

ARROW_NS_TILEID EQU $48
STOP_NS_TILEID  EQU $4a
ARROW_EW_TILEID EQU $4c
STOP_EW_TILEID  EQU $4e

ELEPHANT_SL1_TILEID EQU $00
ELEPHANT_NL1_TILEID EQU $08
ELEPHANT_WL1_TILEID EQU $10

GOAT_SL1_TILEID EQU $18
GOAT_NL1_TILEID EQU $20
GOAT_WL1_TILEID EQU $28

MOUSE_SL1_TILEID EQU $30
MOUSE_NL1_TILEID EQU $38
MOUSE_WL1_TILEID EQU $40

PIPE_WL_TILEID EQU $8c
PIPE_EL_TILEID EQU $90

;;;=========================================================================;;;

SECTION "PuzzleObjState", WRAM0

;;; A counter that is incremented once per frame and that can be used to drive
;;; looping animations.
Ram_PuzzleAnimationClock_u8::
    DB

;;; The number of frames left until the currently-moving animal reaches the
;;; next position.
Ram_WalkingCountdown_u8::
    DB

;;; Which action the currently-moving animal is performing, or zero for none.
Ram_WalkingAction_u8::
    DB

;;;=========================================================================;;;

SECTION "PuzzleObjFunctions", ROM0

Func_PuzzleInitObjs::
    ;; Set up animal objects.
    ld a, ANIMAL_MOUSE
    ld [Ram_SelectedAnimal_u8], a
    call Func_UpdateSelectedAnimalObjs
    ld a, ANIMAL_GOAT
    ld [Ram_SelectedAnimal_u8], a
    call Func_UpdateSelectedAnimalObjs
    ld a, ANIMAL_ELEPHANT
    ld [Ram_SelectedAnimal_u8], a
    call Func_UpdateSelectedAnimalObjs
    ;; Set up arrow objects.
    ld a, ARROW_PALETTE
    ld [Ram_ArrowN_oama + OAMA_FLAGS], a
    ld [Ram_ArrowE_oama + OAMA_FLAGS], a
    ld a, ARROW_PALETTE | OAMF_XFLIP
    ld [Ram_ArrowW_oama + OAMA_FLAGS], a
    ld a, ARROW_PALETTE | OAMF_YFLIP
    ld [Ram_ArrowS_oama + OAMA_FLAGS], a
    call Func_UpdateMoveDirs
    ;; Set up pipe objects.
    ld a, PIPE_WL_TILEID
    ld [Ram_PipeWL_oama + OAMA_TILEID], a
    add 2
    ld [Ram_PipeWR_oama + OAMA_TILEID], a
    ld a, PIPE_EL_TILEID
    ld [Ram_PipeEL_oama + OAMA_TILEID], a
    add 2
    ld [Ram_PipeER_oama + OAMA_TILEID], a
    ld a, PIPE_PALETTE | OAMF_PRI
    ld [Ram_PipeWL_oama + OAMA_FLAGS], a
    ld [Ram_PipeWR_oama + OAMA_FLAGS], a
    ld [Ram_PipeEL_oama + OAMA_FLAGS], a
    ld [Ram_PipeER_oama + OAMA_FLAGS], a
    ;; Set up teleport objects.
    ld a, SMOKE_PALETTE
    ld [Ram_TeleportL_oama + OAMA_FLAGS], a
    ld [Ram_TeleportR_oama + OAMA_FLAGS], a
    ret

;;;=========================================================================;;;

;;; Updates the X, Y, and TILEID fields for all four Ram_Arrow?_oama objects,
;;; based on the Position/MoveDirs of the currently selected animal.
Func_UpdateArrowObjs::
    ;; Store selected animal's position in b and movedirs in d.
    call Func_GetSelectedAnimalPtr_hl
    ASSERT ANIM_Position_u8 == 0
    ld b, [hl]
    ld a, [Ram_MoveDirs_u8]
    ld d, a
    ;; Store the animal's obj left in c and top in b.
    ld a, b
    and $0f
    swap a
    add 8
    ld c, a
    add 4
    ld [Ram_ArrowN_oama + OAMA_X], a
    ld [Ram_ArrowS_oama + OAMA_X], a
    ld a, b
    and $f0
    add 16
    ld b, a
    ld [Ram_ArrowE_oama + OAMA_Y], a
    ld [Ram_ArrowW_oama + OAMA_Y], a
    ;; Store (clock % 32 >= 16 ? 1 : 0) in e.
    ld a, [Ram_PuzzleAnimationClock_u8]
    and %00010000
    swap a
    ld e, a
_UpdateArrowObjs_North:
    bit DIRB_NORTH, d
    jr z, .shapeStop
    ld a, ARROW_NS_TILEID
    jr .endShape
    .shapeStop
    ld a, STOP_NS_TILEID
    .endShape
    ld [Ram_ArrowN_oama + OAMA_TILEID], a
    ld a, b
    sub 16
    sub e
    ld [Ram_ArrowN_oama + OAMA_Y], a
_UpdateArrowObjs_South:
    bit DIRB_SOUTH, d
    jr z, .shapeStop
    ld a, ARROW_NS_TILEID
    jr .endShape
    .shapeStop
    ld a, STOP_NS_TILEID
    .endShape
    ld [Ram_ArrowS_oama + OAMA_TILEID], a
    ld a, b
    add 16
    add e
    ld [Ram_ArrowS_oama + OAMA_Y], a
_UpdateArrowObjs_East:
    bit DIRB_EAST, d
    jr z, .shapeStop
    ld a, ARROW_EW_TILEID
    jr .endShape
    .shapeStop
    ld a, STOP_EW_TILEID
    .endShape
    ld [Ram_ArrowE_oama + OAMA_TILEID], a
    ld a, c
    add 17
    add e
    ld [Ram_ArrowE_oama + OAMA_X], a
_UpdateArrowObjs_West:
    bit DIRB_WEST, d
    jr z, .shapeStop
    ld a, ARROW_EW_TILEID
    jr .endShape
    .shapeStop
    ld a, STOP_EW_TILEID
    .endShape
    ld [Ram_ArrowW_oama + OAMA_TILEID], a
    ld a, c
    sub 9
    sub e
    ld [Ram_ArrowW_oama + OAMA_X], a
    ret

;;;=========================================================================;;;

;;; Updates the TILEID and FLAGS fields for the objects for each animal that's
;;; at its goal, based on Ram_PuzzleAnimationClock_u8.
Func_UpdateAllHappyAnimalObjs::
    ld d, $ff  ; param: except
    jr Func_UpdateHappyAnimalObjs

;;; Updates the TILEID and FLAGS fields for the objects for each animal that's
;;; at its goal, based on Ram_PuzzleAnimationClock_u8, except for the
;;; currently-selected animal.
Func_UpdateUnselectedHappyAnimalObjs::
    ld a, [Ram_SelectedAnimal_u8]
    ld d, a  ; param: except
    ;; fall through to Func_UpdateHappyAnimalObjs

;;; Helper function for the above Func_Update*HappyAnimalObjs functions.
;;; Updates the TILEID and FLAGS fields for the objects for each animal that's
;;; at its goal, based on Ram_PuzzleAnimationClock_u8, except for the specified
;;; animal.
;;; @param d Don't update objects for this animal (one of the ANIMAL_*
;;;     constants, or $ff to not skip any animals).
Func_UpdateHappyAnimalObjs:
    ;; Store (clock % 16 >= 8 ? 4 : 0) in e.
    ld a, [Ram_PuzzleAnimationClock_u8]
    and %00001000
    rrca
    ld e, a
_UpdateHappyAnimalObjs_Elephant:
    ld a, d
    if_eq ANIMAL_ELEPHANT, jr, .skipElephant
    ld a, [Ram_PuzzleState_puzz + PUZZ_Elephant_anim + ANIM_Position_u8]
    ASSERT LOW(Ram_PuzzleState_puzz) == 0
    ld h, HIGH(Ram_PuzzleState_puzz)
    ld l, a
    ld a, [hl]
    if_ne G_PNT, jr, .skipElephant
    ld a, ELEPHANT_SL1_TILEID
    add e
    ld [Ram_ElephantL_oama + OAMA_TILEID], a
    add 2
    ld [Ram_ElephantR_oama + OAMA_TILEID], a
    ld a, ELEPHANT_PALETTE
    ld [Ram_ElephantL_oama + OAMA_FLAGS], a
    ld [Ram_ElephantR_oama + OAMA_FLAGS], a
    .skipElephant
_UpdateHappyAnimalObjs_Goat:
    ld a, d
    if_eq ANIMAL_GOAT, jr, .skipGoat
    ld a, [Ram_PuzzleState_puzz + PUZZ_Goat_anim + ANIM_Position_u8]
    ASSERT LOW(Ram_PuzzleState_puzz) == 0
    ld h, HIGH(Ram_PuzzleState_puzz)
    ld l, a
    ld a, [hl]
    if_ne G_APL, jr, .skipGoat
    ld a, GOAT_SL1_TILEID
    add e
    ld [Ram_GoatL_oama + OAMA_TILEID], a
    add 2
    ld [Ram_GoatR_oama + OAMA_TILEID], a
    ld a, GOAT_PALETTE
    ld [Ram_GoatL_oama + OAMA_FLAGS], a
    ld [Ram_GoatR_oama + OAMA_FLAGS], a
    .skipGoat
_UpdateHappyAnimalObjs_Mouse:
    ld a, d
    if_eq ANIMAL_MOUSE, ret
    ld a, [Ram_PuzzleState_puzz + PUZZ_Mouse_anim + ANIM_Position_u8]
    ASSERT LOW(Ram_PuzzleState_puzz) == 0
    ld h, HIGH(Ram_PuzzleState_puzz)
    ld l, a
    ld a, [hl]
    if_ne G_CHS, ret
    ld a, MOUSE_SL1_TILEID
    add e
    ld [Ram_MouseL_oama + OAMA_TILEID], a
    add 2
    ld [Ram_MouseR_oama + OAMA_TILEID], a
    ld a, MOUSE_PALETTE
    ld [Ram_MouseL_oama + OAMA_FLAGS], a
    ld [Ram_MouseR_oama + OAMA_FLAGS], a
    ret

;;;=========================================================================;;;

;;; Updates the shadow OAMA struct for the currently selected animal.
Func_UpdateSelectedAnimalObjs::
    ld a, [Ram_SelectedAnimal_u8]
    if_eq ANIMAL_MOUSE, jp, _UpdateSelectedAnimalObjs_Mouse
    if_eq ANIMAL_GOAT, jp, _UpdateSelectedAnimalObjs_Goat
_UpdateSelectedAnimalObjs_Elephant:
    ;; Store the walking offset in c.
    ld a, [Ram_WalkingCountdown_u8]
    ld c, a
    ;; Store the facing direction in b.
    ld a, [Ram_PuzzleState_puzz + PUZZ_Elephant_anim + ANIM_Facing_u8]
    ld b, a
_UpdateSelectedAnimalObjs_ElephantYPosition:
    ld a, [Ram_PuzzleState_puzz + PUZZ_Elephant_anim + ANIM_Position_u8]
    and $f0
    add 16
    bit DIRB_NORTH, b
    jr z, .notNorth
    add c
    jr .notSouth
    .notNorth
    bit DIRB_SOUTH, b
    jr z, .notSouth
    sub c
    .notSouth
    ld [Ram_ElephantL_oama + OAMA_Y], a
    ld [Ram_ElephantR_oama + OAMA_Y], a
_UpdateSelectedAnimalObjs_ElephantXPosition:
    ld a, [Ram_PuzzleState_puzz + PUZZ_Elephant_anim + ANIM_Position_u8]
    and $0f
    swap a
    add 8
    bit DIRB_WEST, b
    jr z, .notWest
    add c
    jr .notEast
    .notWest
    bit DIRB_EAST, b
    jr z, .notEast
    sub c
    .notEast
    ld [Ram_ElephantL_oama + OAMA_X], a
    add 8
    ld [Ram_ElephantR_oama + OAMA_X], a
_UpdateSelectedAnimalObjs_ElephantTileAndFlags:
    ld a, c
    and %00001000
    rrca
    bit DIRB_EAST, b
    jr z, .notEast
    add ELEPHANT_WL1_TILEID
    ld [Ram_ElephantR_oama + OAMA_TILEID], a
    add 2
    ld [Ram_ElephantL_oama + OAMA_TILEID], a
    ld a, ELEPHANT_PALETTE | OAMF_XFLIP
    ld [Ram_ElephantL_oama + OAMA_FLAGS], a
    ld [Ram_ElephantR_oama + OAMA_FLAGS], a
    ret
    .notEast
    bit DIRB_WEST, b
    jr z, .notWest
    add ELEPHANT_WL1_TILEID
    jr .finish
    .notWest
    bit DIRB_NORTH, b
    jr z, .notNorth
    add ELEPHANT_NL1_TILEID
    jr .finish
    .notNorth
    bit DIRB_SOUTH, b
    jr z, .finish
    add ELEPHANT_SL1_TILEID
    .finish
    ld [Ram_ElephantL_oama + OAMA_TILEID], a
    add 2
    ld [Ram_ElephantR_oama + OAMA_TILEID], a
    ld a, ELEPHANT_PALETTE
    ld [Ram_ElephantL_oama + OAMA_FLAGS], a
    ld [Ram_ElephantR_oama + OAMA_FLAGS], a
    ret

_UpdateSelectedAnimalObjs_Goat:
    ld a, [Ram_WalkingAction_u8]
    ld e, a
    ;; Calculate and store the walking offset in c.
    ld a, [Ram_WalkingCountdown_u8]
    bit ACTB_LEAP, e
    jr z, .hopping
    .leaping
    if_ge 21, jr, .beforeLeap
    if_lt 5, jr, .afterJump
    .midLeap
    sub 4
    jr .doneJumping
    .beforeLeap
    ld a, 16
    jr .doneJumping
    .hopping
    if_ge 11, jr, .beforeHop
    if_lt 3, jr, .afterJump
    .midHop
    sub 2
    jr .doneJumping
    .beforeHop
    ld a, 8
    jr .doneJumping
    .afterJump
    xor a
    .doneJumping
    rlca
    ld c, a
    ;; Store the facing direction in b.
    ld a, [Ram_PuzzleState_puzz + PUZZ_Goat_anim + ANIM_Facing_u8]
    ld b, a
_UpdateSelectedAnimalObjs_GoatYPosition:
    ld a, [Ram_PuzzleState_puzz + PUZZ_Goat_anim + ANIM_Position_u8]
    and $f0
    add 16
    bit DIRB_NORTH, b
    jr z, .notNorth
    add c
    jr .notSouth
    .notNorth
    bit DIRB_SOUTH, b
    jr z, .notSouth
    sub c
    .notSouth
    ;; If the goat is leaping, use the leap table.
    bit 0, e
    jr z, .notLeaping
    ld d, a
    ld a, c
    rrca
    add LOW(Data_GoatLeapTable)
    ld l, a
    ld h, HIGH(Data_GoatLeapTable)
    ld a, d
    sub [hl]
    jr .doneLeaping
    ;; Otherwise, use the hop table.
    .notLeaping
    ld d, a
    ld a, c
    rrca
    add LOW(Data_GoatHopTable)
    ld l, a
    ld h, HIGH(Data_GoatHopTable)
    ld a, d
    sub [hl]
    ;; Set the goat objects' Y-positions.
    .doneLeaping
    ld [Ram_GoatL_oama + OAMA_Y], a
    ld [Ram_GoatR_oama + OAMA_Y], a
_UpdateSelectedAnimalObjs_GoatXPosition:
    ld a, [Ram_PuzzleState_puzz + PUZZ_Goat_anim + ANIM_Position_u8]
    and $0f
    swap a
    add 8
    bit DIRB_WEST, b
    jr z, .notWest
    add c
    jr .notEast
    .notWest
    bit DIRB_EAST, b
    jr z, .notEast
    sub c
    .notEast
    ld [Ram_GoatL_oama + OAMA_X], a
    add 8
    ld [Ram_GoatR_oama + OAMA_X], a
_UpdateSelectedAnimalObjs_GoatTileAndFlags:
    ld a, c
    and %00000100
    bit DIRB_EAST, b
    jr z, .notEast
    add GOAT_WL1_TILEID
    ld [Ram_GoatR_oama + OAMA_TILEID], a
    add 2
    ld [Ram_GoatL_oama + OAMA_TILEID], a
    ld a, GOAT_PALETTE | OAMF_XFLIP
    ld [Ram_GoatL_oama + OAMA_FLAGS], a
    ld [Ram_GoatR_oama + OAMA_FLAGS], a
    ret
    .notEast
    bit DIRB_WEST, b
    jr z, .notWest
    add GOAT_WL1_TILEID
    jr .finish
    .notWest
    bit DIRB_NORTH, b
    jr z, .notNorth
    add GOAT_NL1_TILEID
    jr .finish
    .notNorth
    bit DIRB_SOUTH, b
    jr z, .finish
    add GOAT_SL1_TILEID
    .finish
    ld [Ram_GoatL_oama + OAMA_TILEID], a
    add 2
    ld [Ram_GoatR_oama + OAMA_TILEID], a
    ld a, GOAT_PALETTE
    ld [Ram_GoatL_oama + OAMA_FLAGS], a
    ld [Ram_GoatR_oama + OAMA_FLAGS], a
    ret

_UpdateSelectedAnimalObjs_Mouse:
    ;; Calculate and store the walking offset in c.
    ld a, [Ram_WalkingCountdown_u8]
    rlca
    ld c, a
    ;; Store the facing direction in b.
    ld a, [Ram_PuzzleState_puzz + PUZZ_Mouse_anim + ANIM_Facing_u8]
    ld b, a
_UpdateSelectedAnimalObjs_MouseYPosition:
    ld a, [Ram_PuzzleState_puzz + PUZZ_Mouse_anim + ANIM_Position_u8]
    and $f0
    add 16
    bit DIRB_NORTH, b
    jr z, .notNorth
    add c
    jr .notSouth
    .notNorth
    bit DIRB_SOUTH, b
    jr z, .notSouth
    sub c
    .notSouth
    ld [Ram_MouseL_oama + OAMA_Y], a
    ld [Ram_MouseR_oama + OAMA_Y], a
_UpdateSelectedAnimalObjs_MouseXPosition:
    ld a, [Ram_PuzzleState_puzz + PUZZ_Mouse_anim + ANIM_Position_u8]
    and $0f
    swap a
    add 8
    bit DIRB_WEST, b
    jr z, .notWest
    add c
    jr .notEast
    .notWest
    bit DIRB_EAST, b
    jr z, .notEast
    sub c
    .notEast
    ld [Ram_MouseL_oama + OAMA_X], a
    add 8
    ld [Ram_MouseR_oama + OAMA_X], a
_UpdateSelectedAnimalObjs_MouseTileAndFlags:
    ld a, [Ram_WalkingAction_u8]
    ld e, a
    ld a, c
    and %00000100
    bit DIRB_EAST, b
    jr z, .notEast
    add MOUSE_WL1_TILEID
    ld [Ram_MouseR_oama + OAMA_TILEID], a
    add 2
    ld [Ram_MouseL_oama + OAMA_TILEID], a
    ld a, MOUSE_PALETTE | OAMF_XFLIP
    jr .setFlags
    .notEast
    bit DIRB_WEST, b
    jr z, .notWest
    add MOUSE_WL1_TILEID
    jr .finish
    .notWest
    bit DIRB_NORTH, b
    jr z, .notNorth
    add MOUSE_NL1_TILEID
    jr .finish
    .notNorth
    bit DIRB_SOUTH, b
    jr z, .finish
    add MOUSE_SL1_TILEID
    .finish
    ld [Ram_MouseL_oama + OAMA_TILEID], a
    add 2
    ld [Ram_MouseR_oama + OAMA_TILEID], a
    ;; If the mouse is going under a mouse hole, put its objects behind the
    ;; background.
    ld a, MOUSE_PALETTE
    .setFlags
    bit ACTB_UNDER, e
    jr z, .over
    or OAMF_PRI
    .over
    ld [Ram_MouseL_oama + OAMA_FLAGS], a
    ld [Ram_MouseR_oama + OAMA_FLAGS], a
    ret

;;;=========================================================================;;;

;;; Changes the tile IDs (and clears OAMA flags) for the selected animal,
;;; without changing the positions of its objects.
;;; @param d The tile ID for the left side of the animal.
Func_SetSelectedAnimalTiles::
    ld a, [Ram_SelectedAnimal_u8]
    if_eq ANIMAL_MOUSE, jr, _SetSelectedAnimalTiles_Mouse
    if_eq ANIMAL_GOAT, jr, _SetSelectedAnimalTiles_Goat
_SetSelectedAnimalTiles_Elephant:
    ld a, d
    ld [Ram_ElephantL_oama + OAMA_TILEID], a
    add 2
    ld [Ram_ElephantR_oama + OAMA_TILEID], a
    ld a, SMOKE_PALETTE
    ld [Ram_ElephantL_oama + OAMA_FLAGS], a
    ld [Ram_ElephantR_oama + OAMA_FLAGS], a
    ret
_SetSelectedAnimalTiles_Goat:
    ld a, d
    ld [Ram_GoatL_oama + OAMA_TILEID], a
    add 2
    ld [Ram_GoatR_oama + OAMA_TILEID], a
    ld a, SMOKE_PALETTE
    ld [Ram_GoatL_oama + OAMA_FLAGS], a
    ld [Ram_GoatR_oama + OAMA_FLAGS], a
    ret
_SetSelectedAnimalTiles_Mouse:
    ld a, d
    ld [Ram_MouseL_oama + OAMA_TILEID], a
    add 2
    ld [Ram_MouseR_oama + OAMA_TILEID], a
    ld a, SMOKE_PALETTE
    ld [Ram_MouseL_oama + OAMA_FLAGS], a
    ld [Ram_MouseR_oama + OAMA_FLAGS], a
    ret

;;;=========================================================================;;;

SECTION "GoatLeapTable", ROM0, ALIGN[5]
Data_GoatHopTable:
    DB 0, 2, 3, 4, 4, 4, 3, 2, 0
Data_GoatLeapTable:
    DB 0, 2, 4, 5, 6, 7, 8, 8, 8, 8, 8, 7, 6, 5, 4, 2, 0

;;;=========================================================================;;;
