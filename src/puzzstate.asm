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

INCLUDE "src/macros.inc"
INCLUDE "src/puzzle.inc"

;;;=========================================================================;;;

SECTION "PuzzleState", WRAM0, ALIGN[8]

;;; A 256-byte-aligned in-RAM copy of the current puzzle's ROM data, possibly
;;; mutated from its original state.
Ram_PuzzleState_puzz::
    DS sizeof_PUZZ

;;; The number of moves the player has made so far.
Ram_PuzzleNumMoves_bcd16::
    DW

;;; This should be set to one of the ANIMAL_* constants.
Ram_SelectedAnimal_u8::
    DB

;;; A bitfield indicating in which directions the currently-selected animal can
;;; move.  This uses the DIRB_* and DIRF_* constants.
Ram_MoveDirs_u8::
    DB

;;;=========================================================================;;;

SECTION "PuzzleStateFunctions", ROM0

;;; Returns a pointer to the ANIM struct of the currently selected animal.
;;; @return hl A pointer to an ANIM struct.
;;; @preserve bc, de
Func_GetSelectedAnimalPtr_hl::
    ld a, [Ram_SelectedAnimal_u8]
    if_eq ANIMAL_MOUSE, jr, .mouseSelected
    if_eq ANIMAL_GOAT, jr, .goatSelected
    .elephantSelected
    ld hl, Ram_PuzzleState_puzz + PUZZ_Elephant_anim
    ret
    .goatSelected
    ld hl, Ram_PuzzleState_puzz + PUZZ_Goat_anim
    ret
    .mouseSelected
    ld hl, Ram_PuzzleState_puzz + PUZZ_Mouse_anim
    ret

;;; @return fc True if the selected animal is alive.
Func_IsSelectedAnimalAlive_fc::
    call Func_GetSelectedAnimalPtr_hl
    ASSERT ANIM_Position_u8 == 0
    ld a, [hl]
    and $0f
    cp TERRAIN_COLS
    ret

;;;=========================================================================;;;

;;; Updates Ram_MoveDirs_u8 for the currently selected animal.
Func_UpdateMoveDirs::
    ;; Store the animal's current position in l.
    call Func_GetSelectedAnimalPtr_hl
    ASSERT ANIM_Position_u8 == 0
    ld l, [hl]
    ;; Make hl point to the terrain cell for the animal's current position.
    ASSERT LOW(Ram_PuzzleState_puzz) == 0
    ld h, HIGH(Ram_PuzzleState_puzz)
    ;; We'll track the new value for Ram_MoveDirs_u8 in b.  To start with,
    ;; initialize it to allow all four dirations.
    ld b, DIRF_NORTH | DIRF_SOUTH | DIRF_EAST | DIRF_WEST
    ld c, l
_UpdateMoveDirs_West:
    ld d, DIRF_WEST
    call Func_IsBlocked_fz  ; preserves bc and h
    jr nz, .unblocked
    res DIRB_WEST, b
    .unblocked
    ld l, c
_UpdateMoveDirs_East:
    ld d, DIRF_EAST
    call Func_IsBlocked_fz  ; preserves bc and h
    jr nz, .unblocked
    res DIRB_EAST, b
    .unblocked
    ld l, c
_UpdateMoveDirs_North:
    ld d, DIRF_NORTH
    call Func_IsBlocked_fz  ; preserves bc and h
    jr nz, .unblocked
    res DIRB_NORTH, b
    .unblocked
    ld l, c
_UpdateMoveDirs_South:
    ld d, DIRF_SOUTH
    call Func_IsBlocked_fz  ; preserves b
    jr nz, .unblocked
    res DIRB_SOUTH, b
    .unblocked
_UpdateMoveDirs_Finish:
    ld a, b
    ld [Ram_MoveDirs_u8], a
    ret

;;;=========================================================================;;;

;;; @param hl A pointer to starting terrain cell in Ram_PuzzleState_puzz.
;;; @param d The direction to check (one of the DIRF_* values).
;;; @return fz True if the position is blocked by a wall or animal.
;;; @preserve bc, d, h
Func_IsBlocked_fz:
    ;; Use e to store whether we have jumped a river (initially false).
    ld e, 0
_IsBlocked_Check:
    bit DIRB_WEST, d
    jr nz, _IsBlocked_CheckWest
    bit DIRB_EAST, d
    jr nz, _IsBlocked_CheckEast
    bit DIRB_SOUTH, d
    jr nz, _IsBlocked_CheckSouth
_IsBlocked_CheckNorth:
    ;; Check if we're on the north edge of the screen.
    ld a, l
    and $f0
    jp z, _IsBlocked_Yes
    ;; Otherwise, prepare to subtract 16 from l.
    ld a, $f0
    jr _IsBlocked_Advance
_IsBlocked_CheckSouth:
    ;; Check if we're on the south edge of the screen.
    ld a, l
    and $f0
    if_ge (16 * (TERRAIN_ROWS - 1)), jr, _IsBlocked_Yes
    ;; Otherwise, prepare to add 16 to l.
    ld a, $10
    jr _IsBlocked_Advance
_IsBlocked_CheckEast:
    ;; Check if we're on the east edge of the screen.
    ld a, l
    and $0f
    if_ge (TERRAIN_COLS - 1), jr, _IsBlocked_Yes
    ;; Otherwise, prepare to add 1 to l.
    ld a, $01
    jr _IsBlocked_Advance
_IsBlocked_CheckWest:
    ;; Check if we're on the west edge of the screen.
    ld a, l
    and $0f
    jr z, _IsBlocked_Yes
    ;; Otherwise, prepare to subtract 1 from l.
    ld a, $ff
_IsBlocked_Advance:
    add l
    ld l, a
    ;; Check for a wall:
    ld a, [hl]
    if_ge W_MIN, jr, _IsBlocked_Yes
    ;; Check for a mousehole:
    if_lt M_MIN, jr, .noMousehole
    ld a, [Ram_SelectedAnimal_u8]
    if_ne ANIMAL_MOUSE, jr, _IsBlocked_Yes
    .noMousehole
    ;; Check for a river:
    if_lt R_MIN, jr, .noRiver
    bit 0, e
    jr nz, _IsBlocked_Yes
    ld a, [Ram_SelectedAnimal_u8]
    if_ne ANIMAL_GOAT, jr, _IsBlocked_Yes
    ld e, 1
    jr _IsBlocked_Check
    .noRiver
    ;; Check for a west pipe:
    if_ne S_PPW, jr, .noPipeWest
    ld a, [Ram_SelectedAnimal_u8]
    if_ne ANIMAL_ELEPHANT, jr, _IsBlocked_Yes
    ld a, d
    if_ne DIRF_EAST, jr, _IsBlocked_Yes
    inc l
    inc l
    jr _IsBlocked_ByAnimal
    .noPipeWest
    ;; Check for an east pipe:
    if_ne S_PPE, jr, .noPipeEast
    ld a, [Ram_SelectedAnimal_u8]
    if_ne ANIMAL_ELEPHANT, jr, _IsBlocked_Yes
    ld a, d
    if_ne DIRF_WEST, jr, _IsBlocked_Yes
    dec l
    dec l
    jr _IsBlocked_ByAnimal
    .noPipeEast
    ;; Check for a bush:
    if_ne S_BSH, jr, .noBush
    ld a, [Ram_SelectedAnimal_u8]
    if_ne ANIMAL_GOAT, jr, _IsBlocked_Yes
    .noBush
_IsBlocked_ByAnimal:
    ;; Otherwise, check for an animal:
    ld a, [Ram_PuzzleState_puzz + PUZZ_Elephant_anim + ANIM_Position_u8]
    cp l
    ret z
    ld a, [Ram_PuzzleState_puzz + PUZZ_Goat_anim + ANIM_Position_u8]
    cp l
    ret z
    ld a, [Ram_PuzzleState_puzz + PUZZ_Mouse_anim + ANIM_Position_u8]
    cp l
    ret
_IsBlocked_Yes:
    xor a  ; set z flag
    ret

;;;=========================================================================;;;
