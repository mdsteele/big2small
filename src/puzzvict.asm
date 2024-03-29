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
INCLUDE "src/primitive.inc"
INCLUDE "src/puzzle.inc"
INCLUDE "src/save.inc"

;;;=========================================================================;;;

SECTION "MainVictory", ROM0

Main_Victory::
    ;; Determine if we made par, then play an appropriate victory jingle.
    ld hl, Ram_PuzzleNumMoves_bcd16 + 1
    ld a, [Ram_PuzzleState_puzz + PUZZ_Par_bcd16 + 1]
    if_lt [hl], jr, .didNotMakePar
    ld a, [Ram_PuzzleState_puzz + PUZZ_Par_bcd16 + 0]
    dec hl
    if_lt [hl], jr, .didNotMakePar
    .madePar
    PLAY_SFX1 DataX_VictoryPar_sfx1
    jr .done
    .didNotMakePar
    PLAY_SFX1 DataX_VictoryNoPar_sfx1
    .done
_Victory_AnimateJumping:
    ;; Animate the animals jumping up and down four times.
    ld b, 4 * 16
    .loop
    push bc
    call Func_VictoryHopAnimalObjs
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_AnimateTiles
    pop bc
    xor a
    or b
    jr z, .done
    dec b
    jr .loop
    .done
_Victory_Delay:
    ;; Wait for a few frames.
    ld b, 10
    .loop
    push bc
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_AnimateTiles
    pop bc
    dec b
    jr nz, .loop
_Victory_OutroDialog:
    ld a, [Ram_PuzzleSkipOutroDialog_bool]
    ld hl, Ram_PuzzleState_puzz + PUZZ_Outro_dlog_bptr  ; param: dialog
    ld de, Func_DialogNullUpdate  ; param: update function
    or a
    call z, Func_RunDialog
    call Func_FadeOut
_Victory_CheckForNewRecord:
    ;; If we've just solved this puzzle for the first time, record the current
    ;; move count as the new best record for this puzzle.
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    ld h, HIGH(Ram_Progress_file + FILE_PuzzleStatus_u8_arr)
    ASSERT LOW(Ram_Progress_file + FILE_PuzzleStatus_u8_arr) == 0
    ld l, a
    bit STATB_SOLVED, [hl]
    jr z, .recordNewRecord
    ;; Otherwise, we need to compare the current move count to the previous
    ;; record.  Start by setting bc to the previous record for this puzzle.
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    ASSERT sizeof_BCD16 * NUM_PUZZLES < $100
    mult sizeof_BCD16
    ldb de, a
    ld hl, Ram_Progress_file + FILE_PuzzleBest_bcd16_arr
    add hl, de
    deref bc, hl
    ;; If the current move count is strictly less than the previous record,
    ;; then record it as a new record.
    ld hl, Ram_PuzzleNumMoves_bcd16 + 1
    ld a, [hl-]
    if_lt b, jr, .recordNewRecord
    if_ne b, jr, .noNewRecord
    ld a, [hl]
    if_lt c, jr, .recordNewRecord
    jr .noNewRecord
    ;; If we need to record a new record, save it into the current progress
    ;; file.
    .recordNewRecord
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    ASSERT sizeof_BCD16 * NUM_PUZZLES < $100
    mult sizeof_BCD16
    ldb bc, a
    ld hl, Ram_Progress_file + FILE_PuzzleBest_bcd16_arr
    add hl, bc
    ld a, [Ram_PuzzleNumMoves_bcd16 + 0]
    ld [hl+], a
    ld a, [Ram_PuzzleNumMoves_bcd16 + 1]
    ld [hl], a
    call Func_SaveFile
    .noNewRecord
_Victory_ReturnToAreaMap:
    ;; Determine if we made par, then return to the area map.
    ld c, STATF_SOLVED  ; param: puzzle status
    ld hl, Ram_PuzzleNumMoves_bcd16 + 1
    ld a, [Ram_PuzzleState_puzz + PUZZ_Par_bcd16 + 1]
    if_lt [hl], jr, .didNotMakePar
    ld a, [Ram_PuzzleState_puzz + PUZZ_Par_bcd16 + 0]
    dec hl
    if_lt [hl], jr, .didNotMakePar
    set STATB_MADE_PAR, c
    .didNotMakePar
    jp Main_AreaMapResume

;;;=========================================================================;;;
