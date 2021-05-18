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
INCLUDE "src/save.inc"
INCLUDE "src/tileset.inc"

;;;=========================================================================;;;

SMOKE_L1_TILEID EQU $50
SMOKE_L2_TILEID EQU $54
SMOKE_L3_TILEID EQU $58

TELEPORT_L1_TILEID EQU $5c
TELEPORT_L2_TILEID EQU $60
TELEPORT_L3_TILEID EQU $64

;;; The number of frames per step of the smoke animation:
SMOKE_FRAMES EQU 6

;;; The number of frames per step of the teleport animation:
TELEPORT_FRAMES EQU 3

;;; Sentinel value for Ram_TerrainCellToUpdate_u8:
NO_CELL_TO_UPDATE EQU $ff

;;;=========================================================================;;;

SECTION "PuzzleUiState", WRAM0

;;; If 1, intro/outro dialog is skipped; if 0, dialog is played normally.
Ram_PuzzleSkipIntroDialog_bool:
    DB
Ram_PuzzleSkipOutroDialog_bool::
    DB

;;; Frame counter for the smoke animation.
Ram_SmokeCounter_u8:
    DB

;;; If this is not NO_CELL_TO_UPDATE, then it gives the position of a terrain
;;; cell that needs to be reloaded into the BG map in VRAM after the next
;;; VBlank (because that cell's terrain type changed).
Ram_TerrainCellToUpdate_u8:
    DB

;;;=========================================================================;;;

SECTION "MainPuzzleScreen", ROM0

;;; @prereq LCD is off.
Main_ResetPuzzle::
    ;; Always skip intro dialog when resetting the puzzle.
    ld a, 1
    ld [Ram_PuzzleSkipIntroDialog_bool], a
    jr _BeginPuzzle_Init

;;; @prereq LCD is off.
;;; @param d If nonzero, don't skip dialog even if puzzle is already solved.
Main_BeginPuzzle::
    ;; If d is zero and the puzzle has been solved before, skip dialog.
    ld a, d
    or a
    jr nz, .doNotSkipDialog
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    ld h, HIGH(Ram_Progress_file + FILE_PuzzleStatus_u8_arr)
    ASSERT LOW(Ram_Progress_file + FILE_PuzzleStatus_u8_arr) == 0
    ld l, a
    ld a, 1
    bit STATB_SOLVED, [hl]
    jr nz, .solved
    .doNotSkipDialog
    xor a
    .solved
    ld [Ram_PuzzleSkipIntroDialog_bool], a
    ld [Ram_PuzzleSkipOutroDialog_bool], a
_BeginPuzzle_Init:
    ;; Store pointer to current PUZZ struct in de.
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    rlca
    ldb bc, a
    xld hl, DataX_Puzzles_puzz_ptr_arr
    add hl, bc
    deref de, hl
    romb BANK("PuzzleData")
    ;; Copy current puzzle into RAM.
    ld hl, Ram_PuzzleState_puzz  ; dest
    ld bc, sizeof_PUZZ           ; count
    call Func_MemCopy
    ;; Copy tiles to VRAM.
    ld a, [Ram_PuzzleState_puzz + PUZZ_Tileset_u8]
    ld b, a  ; tileset
    call Func_LoadTileset
    ;; Transfer background color palettes.
    ld a, [Ram_PuzzleState_puzz + PUZZ_Colorset_u8]
    ld c, a  ; colorset
    xcall FuncX_SetBgColorPalettes
    ;; Load terrain map.
    ASSERT LOW(Ram_PuzzleState_puzz) == 0
    ld d, HIGH(Ram_PuzzleState_puzz)
    call Func_LoadPuzzleTerrainIntoVram
    ;; Initialize state.
    xor a
    ld [Ram_PuzzleNumMoves_bcd16 + 0], a
    ld [Ram_PuzzleNumMoves_bcd16 + 1], a
    ld [Ram_PuzzleAnimationClock_u8], a
    ld [Ram_WalkingCountdown_u8], a
    ld [Ram_WalkingAction_u8], a
    ld a, NO_CELL_TO_UPDATE
    ld [Ram_TerrainCellToUpdate_u8], a
    ;; Set up objects.
    call Func_ClearOam
    call Func_PuzzleInitObjs
    ;; Initialize music.
    ld hl, Ram_PuzzleState_puzz + PUZZ_Music_song_bptr
    ld a, [hl+]
    ld c, a   ; param: SONG bank
    deref hl  ; param: SONG ptr
    call Func_MusicStart
    ;; Turn on the LCD and fade in.
    xor a
    ldh [rSCX], a
    ldh [rSCY], a
    call Func_FadeIn
    ld a, %11010000
    ldh [rOBP1], a
    ;; Run intro dialog.
    ld a, [Ram_PuzzleSkipIntroDialog_bool]
    ld hl, Ram_PuzzleState_puzz + PUZZ_Intro_dlog_bptr
    or a
    call z, Func_RunDialog
    ;; fall through to Main_PuzzleCommand

Main_PuzzleCommand::
    call Func_UpdateArrowObjs
    call Func_UpdateAllHappyAnimalObjs
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_UpdatePuzzleTerrain
    call Func_UpdateButtonState
    ld a, [Ram_ButtonsPressed_u8]
    ld b, a
_PuzzleCommand_HandleButtonStart:
    bit PADB_START, b
    jr z, .noPress
    jp Main_BeginPause
    .noPress
_PuzzleCommand_HandleButtonA:
    bit PADB_A, b
    jr z, .noPress
    .increment
    ld a, [Ram_SelectedAnimal_u8]
    inc a
    if_lt 3, jr, .noOverflow
    xor a
    .noOverflow
    ld [Ram_SelectedAnimal_u8], a
    call Func_IsSelectedAnimalAlive_fc
    jr nc, .increment
    call Func_UpdateMoveDirs
    jr Main_PuzzleCommand
    .noPress
_PuzzleCommand_HandleButtonB:
    bit PADB_B, b
    jr z, .noPress
    .decrement
    ld a, [Ram_SelectedAnimal_u8]
    sub 1
    jr nc, .noUnderflow
    ld a, 2
    .noUnderflow
    ld [Ram_SelectedAnimal_u8], a
    call Func_IsSelectedAnimalAlive_fc
    jr nc, .decrement
    call Func_UpdateMoveDirs
    jr Main_PuzzleCommand
    .noPress
_PuzzleCommand_HandleButtonUp:
    bit PADB_UP, b
    jr z, .noPress
    ld d, DIRF_NORTH
    jr _PuzzleCommand_TryMove
    .noPress
_PuzzleCommand_HandleButtonDown:
    bit PADB_DOWN, b
    jr z, .noPress
    ld d, DIRF_SOUTH
    jr _PuzzleCommand_TryMove
    .noPress
_PuzzleCommand_HandleButtonLeft:
    bit PADB_LEFT, b
    jr z, .noPress
    ld d, DIRF_WEST
    jr _PuzzleCommand_TryMove
    .noPress
_PuzzleCommand_HandleButtonRight:
    bit PADB_RIGHT, b
    jr z, Main_PuzzleCommand
    ld d, DIRF_EAST
    jr _PuzzleCommand_TryMove

_PuzzleCommand_TryMove:
    ;; Check if we can move in the DIRF_* direction that's stored in d.
    ld a, [Ram_MoveDirs_u8]
    and d
    jr z, _PuzzleCommand_CannotMove
    ;; We can move, so store d in ANIM_Facing_u8 and switch to AnimalMoving
    ;; mode.
    call Func_GetSelectedAnimalPtr_hl  ; preserves d
    ASSERT ANIM_Facing_u8 == 1
    inc l
    ld [hl], d
    jp Main_AnimalMoving

_PuzzleCommand_CannotMove:
    PLAY_SFX1 DataX_CannotMove_sfx1
    jp Main_PuzzleCommand

;;;=========================================================================;;;

Func_UpdatePuzzleTerrain:
    ;; Update terrain cell if needed:
    ld a, [Ram_TerrainCellToUpdate_u8]
    if_eq NO_CELL_TO_UPDATE, jr, .doneUpdateCell
    ASSERT LOW(Ram_PuzzleState_puzz) == 0
    ld d, HIGH(Ram_PuzzleState_puzz)
    ld e, a
    call Func_LoadTerrainCellIntoVram
    ld a, NO_CELL_TO_UPDATE
    ld [Ram_TerrainCellToUpdate_u8], a
    .doneUpdateCell
    ;; Animate terrain:
    ld hl, Ram_PuzzleAnimationClock_u8
    inc [hl]
    ld c, [hl]  ; animation clock
    ld a, [Ram_PuzzleState_puzz + PUZZ_Tileset_u8]
    ld b, a  ; tileset
    jp Func_AnimateTerrain

;;;=========================================================================;;;

SECTION "MainAnimalMoving", ROM0

Main_AnimalMoving:
    ;; Hide the arrow objects.
    xor a
    ld [Ram_ArrowN_oama + OAMA_Y], a
    ld [Ram_ArrowS_oama + OAMA_Y], a
    ld [Ram_ArrowE_oama + OAMA_Y], a
    ld [Ram_ArrowW_oama + OAMA_Y], a
_AnimalMoving_IncrementNumMoves:
    ;; Don't increment further if we're already at 999 moves.
    ld hl, Ram_PuzzleNumMoves_bcd16
    ld a, [hl+]
    if_ne $99, jr, .increment
    ld a, [hl]
    if_eq $09, jr, .doNotIncrement
    ;; Increment the number of moves.
    .increment
    ld hl, Ram_PuzzleNumMoves_bcd16
    ld a, [hl]
    add 1
    daa
    ld [hl+], a
    ld a, [hl]
    adc 0
    daa
    ld [hl], a
    .doNotIncrement
_AnimalMoving_ContinueMoving:
    ;; Store the old position's terrain type in e.
    call Func_GetSelectedAnimalPtr_hl
    ASSERT ANIM_Position_u8 == 0
    ld c, [hl]
    ASSERT LOW(Ram_PuzzleState_puzz) == 0
    ld b, HIGH(Ram_PuzzleState_puzz)
    ld a, [bc]
    ld e, a
    ;; Store selected animal's ANIM_Facing_u8 in a, and ANIM ptr in hl.
    ASSERT ANIM_Facing_u8 == 1
    inc l
    ld a, [hl-]
    ;; Store the position delta for the animal's current direction in d.
    if_eq DIRF_WEST, jr, .facingWest
    if_eq DIRF_EAST, jr, .facingEast
    if_eq DIRF_SOUTH, jr, .facingSouth
    .facingNorth
    ld d, $f0
    jr .changePos
    .facingSouth
    ld d, $10
    jr .changePos
    .facingEast
    ld d, $01
    jr .changePos
    .facingWest
    ld d, $ff
    .changePos
    ;; Move the animal forward by one square, updating its ANIM_Position_u8.
    ASSERT ANIM_Position_u8 == 0
    ld a, [hl]
    add d
    ld [hl], a
    ;; Prepare for animal-specific animation:
    ld a, [Ram_SelectedAnimal_u8]
    if_eq ANIMAL_MOUSE, jr, _AnimalMoving_ContinueMovingMouse
    if_eq ANIMAL_GOAT, jp, _AnimalMoving_ContinueMovingGoat
_AnimalMoving_ContinueMovingElephant:
    ld a, 16
    ld [Ram_WalkingCountdown_u8], a
    ;; Store the upcoming position's terrain type in a.
    ld e, [hl]
    ASSERT LOW(Ram_PuzzleState_puzz) == 0
    ld d, HIGH(Ram_PuzzleState_puzz)
    ld a, [de]
    ;; If it's a pipe, then we should animate the elephant pushing it.
    if_ne S_PPW, jr, .notPushingEastward
    ld a, ACTF_PUSHE
    ld [Ram_WalkingAction_u8], a
    ld b, 8
    jr .pushingPipe
    .notPushingEastward
    if_ne S_PPE, jr, .notPushingPipe
    ld a, ACTF_PUSHW
    ld [Ram_WalkingAction_u8], a
    ld b, -8
    .pushingPipe
    ;; Set the X-positions of the pipe objects.
    ld a, e
    and $0f
    swap a
    add b
    ld [Ram_PipeWL_oama + OAMA_X], a
    add 8
    ld [Ram_PipeWR_oama + OAMA_X], a
    add 8
    ld [Ram_PipeEL_oama + OAMA_X], a
    add 8
    ld [Ram_PipeER_oama + OAMA_X], a
    ;; Set the Y-positions of the pipe objects.
    ld a, e
    and $f0
    add 16
    ld [Ram_PipeWL_oama + OAMA_Y], a
    ld [Ram_PipeWR_oama + OAMA_Y], a
    ld [Ram_PipeEL_oama + OAMA_Y], a
    ld [Ram_PipeER_oama + OAMA_Y], a
    ;; Change the pushed terrain cell to empty.
    ld a, O_EMP
    ld [de], a
    ld a, e
    ld [Ram_TerrainCellToUpdate_u8], a
    ;; Play a sound effect.
    PLAY_SFX4 DataX_PushPipe_sfx4
    jr _AnimalMoving_RunLoop
    ;; If we're not pushing a pipe, set Ram_WalkingAction_u8 to zero.
    .notPushingPipe
    xor a
    ld [Ram_WalkingAction_u8], a
    jr _AnimalMoving_RunLoop
_AnimalMoving_ContinueMovingMouse:
    ld a, 8
    ld [Ram_WalkingCountdown_u8], a
    ;; If we're coming out of a mouse hole, then we should animate the mouse
    ;; going under it.
    ld a, e
    if_lt M_UNDER_MIN, jr, .notLeavingMouseHole
    if_ge M_UNDER_END, jr, .notLeavingMouseHole
    jr .underMouseHole
    .notLeavingMouseHole
    ;; Store the upcoming position's terrain type in a.
    ld c, [hl]
    ASSERT LOW(Ram_PuzzleState_puzz) == 0
    ld b, HIGH(Ram_PuzzleState_puzz)
    ld a, [bc]
    ;; If we're going into a mouse hole, then we should animate the mouse going
    ;; under it.
    if_lt M_UNDER_MIN, jr, .notEnteringMouseHole
    if_ge M_UNDER_END, jr, .notEnteringMouseHole
    .underMouseHole
    ld a, ACTF_UNDER
    jr .setWalkingAction
    ;; Otherwise, the mouse walks as normal.
    .notEnteringMouseHole
    xor a
    .setWalkingAction
    ld [Ram_WalkingAction_u8], a
    jr _AnimalMoving_RunLoop
_AnimalMoving_ContinueMovingGoat:
    ;; Store the upcoming position's terrain type in a.
    ld c, [hl]
    ASSERT LOW(Ram_PuzzleState_puzz) == 0
    ld b, HIGH(Ram_PuzzleState_puzz)
    ld a, [bc]
    ;; If it's a river, then we should animate the goat leaping over it.
    if_lt R_MIN, jr, .notLeaping
    ld a, [hl]
    add d
    ld [hl], a
    ld a, ACTF_LEAP
    ld [Ram_WalkingAction_u8], a
    ld a, 24
    ld [Ram_WalkingCountdown_u8], a
    PLAY_SFX1 DataX_Leap_sfx1
    jr _AnimalMoving_RunLoop
    ;; Otherwise, the goat hops at a slower pace.
    .notLeaping
    xor a
    ld [Ram_WalkingAction_u8], a
    ld a, 12
    ld [Ram_WalkingCountdown_u8], a
_AnimalMoving_RunLoop:
    call Func_UpdateUnselectedHappyAnimalObjs
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_UpdatePuzzleTerrain
    ;; If the animal is pushing a pipe, animate the pipe moving.
    ld a, [Ram_WalkingAction_u8]
    if_ne ACTF_PUSHW, jr, .notPushingWestward
    ld a, [Ram_PipeWL_oama + OAMA_X]
    sub 1
    jr .pushingPipe
    .notPushingWestward
    if_ne ACTF_PUSHE, jr, .notPushingEastward
    ld a, [Ram_PipeWL_oama + OAMA_X]
    add 1
    .pushingPipe
    ld [Ram_PipeWL_oama + OAMA_X], a
    add 8
    ld [Ram_PipeWR_oama + OAMA_X], a
    add 8
    ld [Ram_PipeEL_oama + OAMA_X], a
    add 8
    ld [Ram_PipeER_oama + OAMA_X], a
    .notPushingEastward
    ;; Move animal forward.
    ld hl, Ram_WalkingCountdown_u8
    dec [hl]
    ;; Check if we've reached the next square.
    jr z, _AnimalMoving_NextPositionReached
    call Func_UpdateSelectedAnimalObjs
    jr _AnimalMoving_RunLoop

_AnimalMoving_NextPositionReached:
    ;; Make de point to the current terrain cell (with e thus being the
    ;; selected animal's position).
    call Func_GetSelectedAnimalPtr_hl
    ASSERT ANIM_Position_u8 == 0
    ld e, [hl]
    ASSERT LOW(Ram_PuzzleState_puzz) == 0
    ld d, HIGH(Ram_PuzzleState_puzz)
    ;; Make hl point to the selected animal's ANIM_Facing_u8.
    ASSERT ANIM_Facing_u8 == 1
    inc l
_AnimalMoving_AnimalAction:
    ld a, [Ram_WalkingAction_u8]
    ;; Check if the animal just finished pushing a pipe eastward.
    if_ne ACTF_PUSHE, jr, .notPushingEastward
    inc e
    inc e
    ld a, S_PPE
    jr .finishPushing
    .notPushingEastward
    ;; Check if the animal just finished pushing a pipe westward.
    if_ne ACTF_PUSHW, jr, .notPushingWestward
    dec e
    dec e
    ld a, S_PPW
    .finishPushing
    ld [de], a
    ld a, e
    ld [Ram_TerrainCellToUpdate_u8], a
    xor a
    ld [Ram_PipeWL_oama + OAMA_Y], a
    ld [Ram_PipeWR_oama + OAMA_Y], a
    ld [Ram_PipeEL_oama + OAMA_Y], a
    ld [Ram_PipeER_oama + OAMA_Y], a
    jp _AnimalMoving_Update
    .notPushingWestward
_AnimalMoving_TerrainAction:
    ;; Store the terrain type the animal is standing on in a.
    ld a, [de]
    if_lt S_MIN, jp, _AnimalMoving_Update  ; fast path for common case
    ;; If the animal steps on an arrow, change the value of its ANIM_Facing_u8.
    if_ne S_ARN, jr, .notNorthArrow
    ld [hl], DIRF_NORTH
    jr .finishArrow
    .notNorthArrow
    if_ne S_ARS, jr, .notSouthArrow
    ld [hl], DIRF_SOUTH
    jr .finishArrow
    .notSouthArrow
    if_ne S_ARE, jr, .notEastArrow
    ld [hl], DIRF_EAST
    jr .finishArrow
    .notEastArrow
    if_ne S_ARW, jr, .notWestArrow
    ld [hl], DIRF_WEST
    .finishArrow
    PLAY_SFX1 DataX_ArrowTerrain_sfx1
    jr _AnimalMoving_Update
    .notWestArrow
    ;; If the animal steps on a matching teleporter, teleport it.
    if_ne S_TEF, jr, .notElephantTeleporterF
    ld a, [Ram_SelectedAnimal_u8]
    if_ne ANIMAL_ELEPHANT, jr, _AnimalMoving_Update
    ld c, $0f
    jp _AnimalMoving_Teleport
    .notElephantTeleporterF
    if_ne S_TGE, jr, .notGoatTeleporterE
    ld a, [Ram_SelectedAnimal_u8]
    if_ne ANIMAL_GOAT, jr, _AnimalMoving_Update
    ld c, $0e
    jr _AnimalMoving_Teleport
    .notGoatTeleporterE
    if_ne S_TME, jr, .notMouseTeleporterE
    ld a, [Ram_SelectedAnimal_u8]
    if_ne ANIMAL_MOUSE, jr, _AnimalMoving_Update
    ld c, $0e
    jr _AnimalMoving_Teleport
    .notMouseTeleporterE
    if_ne S_TMF, jr, .notMouseTeleporterF
    ld a, [Ram_SelectedAnimal_u8]
    if_ne ANIMAL_MOUSE, jr, _AnimalMoving_Update
    ld c, $0f
    jr _AnimalMoving_Teleport
    .notMouseTeleporterF
    ;; If the mouse steps on a mousetrap, then it dies.
    if_ne S_MTP, jr, .notMousetrap
    ld a, [Ram_SelectedAnimal_u8]
    if_ne ANIMAL_MOUSE, jr, _AnimalMoving_Update
    jp _AnimalMoving_Mousetrap
    .notMousetrap
    ;; If the animal steps on a bush, remove the bush.
    if_ne S_BSH, jr, .notBush
    ld a, O_BST
    ld [de], a
    ld a, e
    ld [Ram_TerrainCellToUpdate_u8], a
    PLAY_SFX4 DataX_EatBush_sfx4
    .notBush
_AnimalMoving_Update:
    call Func_UpdateSelectedAnimalObjs
    ;; Check if we can keep going.
    call Func_UpdateMoveDirs
    call Func_GetSelectedAnimalPtr_hl
    ASSERT ANIM_Facing_u8 == 1
    inc l
    ld a, [Ram_MoveDirs_u8]
    and [hl]
    jp nz, _AnimalMoving_ContinueMoving
_AnimalMoving_DoneMoving:
    ;; Time to check if we've solved the puzzle.
    ASSERT LOW(Ram_PuzzleState_puzz) == 0
    ld h, HIGH(Ram_PuzzleState_puzz)
    ;; If the elephant isn't on the peanut, we haven't solved the puzzle.
    ld a, [Ram_PuzzleState_puzz + PUZZ_Elephant_anim + ANIM_Position_u8]
    ld l, a
    ld a, [hl]
    if_ne G_PNT, jp, Main_PuzzleCommand
    ;; If the goat isn't on the apple, we haven't solved the puzzle.
    ld a, [Ram_PuzzleState_puzz + PUZZ_Goat_anim + ANIM_Position_u8]
    ld l, a
    ld a, [hl]
    if_ne G_APL, jp, Main_PuzzleCommand
    ;; If the mouse isn't on the cheese, we haven't solved the puzzle.
    ld a, [Ram_PuzzleState_puzz + PUZZ_Mouse_anim + ANIM_Position_u8]
    ld l, a
    ld a, [hl]
    if_ne G_CHS, jp, Main_PuzzleCommand
    ;; We've solved the puzzle, so go to victory mode.
    jp Main_Victory

_AnimalMoving_Teleport:
    ;; Set b to the destination position.
    ld a, e
    and $f0
    or c
    ld e, a
    ld a, [de]
    ld b, a
    ;; If there's another animal at the teleporter destination, don't teleport.
    ld a, [Ram_PuzzleState_puzz + PUZZ_Elephant_anim + ANIM_Position_u8]
    if_eq b, jr, _AnimalMoving_Update
    ld a, [Ram_PuzzleState_puzz + PUZZ_Goat_anim + ANIM_Position_u8]
    if_eq b, jr, _AnimalMoving_Update
    ld a, [Ram_PuzzleState_puzz + PUZZ_Mouse_anim + ANIM_Position_u8]
    if_eq b, jr, _AnimalMoving_Update
    ;; Place the teleport effect at the animal's current position.
    call Func_GetSelectedAnimalPtr_hl  ; preserves b
    ASSERT ANIM_Position_u8 == 0
    ld a, [hl]
    and $f0
    add 16
    ld [Ram_TeleportL_oama + OAMA_Y], a
    ld [Ram_TeleportR_oama + OAMA_Y], a
    ld a, [hl]
    and $0f
    swap a
    add 8
    ld [Ram_TeleportL_oama + OAMA_X], a
    add 8
    ld [Ram_TeleportR_oama + OAMA_X], a
    ld a, TELEPORT_L1_TILEID
    ld [Ram_TeleportL_oama + OAMA_TILEID], a
    add 2
    ld [Ram_TeleportR_oama + OAMA_TILEID], a
    ;; Set the selected animal's position to the teleporter destination.
    ld [hl], b
    call Func_UpdateSelectedAnimalObjs
    ld d, TELEPORT_L3_TILEID
    call Func_SetSelectedAnimalTiles
    ;; Play a sound effect.
    PLAY_SFX4 DataX_Teleport_sfx4
    ;; Make the animal vanish.
    xor a
    ld [Ram_SmokeCounter_u8], a
_AnimalMoving_TeleportLoop:
    call Func_UpdateUnselectedHappyAnimalObjs
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_UpdatePuzzleTerrain
    ld a, [Ram_SmokeCounter_u8]
    inc a
    ld [Ram_SmokeCounter_u8], a
    if_eq 1 * TELEPORT_FRAMES, jr, .teleport2
    if_eq 2 * TELEPORT_FRAMES, jr, .teleport3
    if_eq 3 * TELEPORT_FRAMES, jr, _AnimalMoving_TeleportFinish
    jr _AnimalMoving_TeleportLoop
    .teleport2
    ld a, TELEPORT_L2_TILEID
    ld [Ram_TeleportL_oama + OAMA_TILEID], a
    add 2
    ld [Ram_TeleportR_oama + OAMA_TILEID], a
    ld d, TELEPORT_L2_TILEID
    call Func_SetSelectedAnimalTiles
    jr _AnimalMoving_TeleportLoop
    .teleport3
    ld a, TELEPORT_L3_TILEID
    ld [Ram_TeleportL_oama + OAMA_TILEID], a
    add 2
    ld [Ram_TeleportR_oama + OAMA_TILEID], a
    ld d, TELEPORT_L1_TILEID
    call Func_SetSelectedAnimalTiles
    jr _AnimalMoving_TeleportLoop
_AnimalMoving_TeleportFinish:
    xor a
    ld [Ram_TeleportL_oama + OAMA_Y], a
    ld [Ram_TeleportR_oama + OAMA_Y], a
    jp _AnimalMoving_Update

_AnimalMoving_Mousetrap:
    ;; Set current terrain to empty.
    ld a, O_EMP
    ld [de], a
    ld a, e
    ld [Ram_TerrainCellToUpdate_u8], a
    ;; Play a sound effect.
    PLAY_SFX4 DataX_Mousetrap_sfx4
    ;; Replace mouse objects with smoke.
    ld d, SMOKE_L1_TILEID
    call Func_SetSelectedAnimalTiles
    xor a
    ld [Ram_SmokeCounter_u8], a
_AnimalMoving_SmokeLoop:
    call Func_UpdateUnselectedHappyAnimalObjs
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_UpdatePuzzleTerrain
    ld a, [Ram_SmokeCounter_u8]
    inc a
    ld [Ram_SmokeCounter_u8], a
    if_eq 1 * SMOKE_FRAMES, jr, .smoke2
    if_eq 2 * SMOKE_FRAMES, jr, .smoke3
    if_eq 3 * SMOKE_FRAMES, jr, .smokeDone
    if_eq 4 * SMOKE_FRAMES, jr, _AnimalMoving_MouseDead
    jr _AnimalMoving_SmokeLoop
    .smoke2
    ld d, SMOKE_L2_TILEID
    call Func_SetSelectedAnimalTiles
    jr _AnimalMoving_SmokeLoop
    .smoke3
    ld d, SMOKE_L3_TILEID
    call Func_SetSelectedAnimalTiles
    jr _AnimalMoving_SmokeLoop
    .smokeDone
    xor a
    ld [Ram_MouseL_oama + OAMA_Y], a
    ld [Ram_MouseR_oama + OAMA_Y], a
    jr _AnimalMoving_SmokeLoop
_AnimalMoving_MouseDead:
    ;; Select goat.
    ld a, ANIMAL_GOAT
    ld [Ram_SelectedAnimal_u8], a
    call Func_UpdateMoveDirs
    ;; Mark mouse as dead.
    xor a
    ld [Ram_PuzzleState_puzz + PUZZ_Mouse_anim + ANIM_Facing_u8], a
    ld a, PUZZ_Mouse_anim + ANIM_Facing_u8
    ld [Ram_PuzzleState_puzz + PUZZ_Mouse_anim + ANIM_Position_u8], a
    jp Main_PuzzleCommand

;;;=========================================================================;;;
