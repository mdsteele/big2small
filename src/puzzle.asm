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
INCLUDE "src/vram.inc"

;;;=========================================================================;;;

ARROW_PALETTE    EQU (OAMF_PAL1 | 0)
ELEPHANT_PALETTE EQU (OAMF_PAL0 | 1)
GOAT_PALETTE     EQU (OAMF_PAL1 | 2)
MOUSE_PALETTE    EQU (OAMF_PAL0 | 3)
PIPE_PALETTE     EQU (OAMF_PAL0 | 7)
SMOKE_PALETTE    EQU (OAMF_PAL0 | 4)

ELEPHANT_SL1_TILEID EQU $00
ELEPHANT_NL1_TILEID EQU $08
ELEPHANT_WL1_TILEID EQU $10

GOAT_SL1_TILEID EQU $18
GOAT_NL1_TILEID EQU $20
GOAT_WL1_TILEID EQU $28

MOUSE_SL1_TILEID EQU $30
MOUSE_NL1_TILEID EQU $38
MOUSE_WL1_TILEID EQU $40

ARROW_NS_TILEID EQU $48
STOP_NS_TILEID  EQU $4a
ARROW_EW_TILEID EQU $4c
STOP_EW_TILEID  EQU $4e

SMOKE_L1_TILEID EQU $50
SMOKE_L2_TILEID EQU $54
SMOKE_L3_TILEID EQU $58

TELEPORT_L1_TILEID EQU $5c
TELEPORT_L2_TILEID EQU $60
TELEPORT_L3_TILEID EQU $64

PIPE_WL_TILEID EQU $f8
PIPE_EL_TILEID EQU $fc

;;; The number of frames per step of the smoke animation:
SMOKE_FRAMES EQU 6

;;; The number of frames per step of the teleport animation:
TELEPORT_FRAMES EQU 3

;;;=========================================================================;;;

;;; Bit indices for Ram_WalkingAction_u8:
ACTB_LEAP  EQU 0  ; leap over river
ACTB_PUSHW EQU 1  ; push pipe westward
ACTB_PUSHE EQU 2  ; push pipe eastward
ACTB_UNDER EQU 3  ; go under a mouse hole

;;; Flags for Ram_WalkingAction_u8:
ACTF_LEAP  EQU (1 << ACTB_LEAP)
ACTF_PUSHW EQU (1 << ACTB_PUSHW)
ACTF_PUSHE EQU (1 << ACTB_PUSHE)
ACTF_UNDER EQU (1 << ACTB_UNDER)

;;;=========================================================================;;;

SECTION "PuzzleState", WRAM0, ALIGN[8]

;;; A 256-byte-aligned in-RAM copy of the current puzzle's ROM data, possibly
;;; mutated from its original state.
Ram_PuzzleState_puzz:
    DS sizeof_PUZZ

;;;=========================================================================;;;

SECTION "PuzzleUiState", WRAM0

;;; A pointer to the original PUZZ struct ROM for the current puzzle.
Ram_PuzzleRom_puzz_ptr:
    DW

;;; This should be set to one of the ANIMAL_* constants.
Ram_SelectedAnimal_u8:
    DB

;;; A bitfield indicating in which directions the currently-selected animal can
;;; move.  This uses the DIRB_* and DIRF_* constants.
Ram_MoveDirs_u8:
    DB

;;; A counter that is incremented once per frame and that can be used to drive
;;; looping animations.
Ram_AnimationClock_u8:
    DB

;;; The number of frames left until the currently-moving animal reaches the
;;; next position.
Ram_WalkingCountdown_u8:
    DB

;;; Which action the currently-moving animal is performing, or zero for none.
Ram_WalkingAction_u8:
    DB

;;; Frame counter for the smoke animation.
Ram_SmokeCounter_u8:
    DB

;;;=========================================================================;;;

SECTION "GoatLeapTable", ROM0, ALIGN[5]
Data_GoatHopTable:
    DB 0, 2, 3, 4, 4, 4, 5, 2, 0
Data_GoatLeapTable:
    DB 0, 2, 4, 5, 6, 7, 8, 8, 8, 8, 8, 7, 6, 5, 4, 2, 0

;;;=========================================================================;;;

SECTION "MainPuzzleScreen", ROM0

;;; @prereq LCD is off.
Main_ResetPuzzle::
    ld a, [Ram_PuzzleRom_puzz_ptr + 0]
    ld e, a
    ld a, [Ram_PuzzleRom_puzz_ptr + 1]
    ld d, a
    jr _BeginPuzzle_Init

;;; @prereq LCD is off.
;;; @param c Current puzzle number.
Main_BeginPuzzle::
    ;; Store pointer to current PUZZ struct in de...
    sla c
    ld b, 0
    ld hl, DataX_Puzzles_puzz_ptr_arr
    add hl, bc
    romb BANK(DataX_Puzzles_puzz_ptr_arr)
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    ;; ... and also in Ram_PuzzleRom_puzz_ptr.
    ld [Ram_PuzzleRom_puzz_ptr + 0], a
    ld a, d
    ld [Ram_PuzzleRom_puzz_ptr + 1], a
_BeginPuzzle_Init:
    ;; At this point, de points to a PUZZ struct in banked ROM.
    romb BANK("PuzzleData")
    ;; Copy current puzzle into RAM.
    ld hl, Ram_PuzzleState_puzz  ; dest
    ld bc, sizeof_PUZZ           ; count
    call Func_MemCopy
    ;; Copy tiles to VRAM.
    ld hl, Vram_SharedTiles  ; dest
    COPY_FROM_ROMX DataX_TerrainTiles_start, DataX_TerrainTiles_end
    ld a, [Ram_PuzzleState_puzz + PUZZ_Tileset_u8]
    if_eq TILESET_CITY, jr, .cityTiles
    if_eq TILESET_FARM, jr, .farmTiles
    if_eq TILESET_SPACE, jr, .spaceTiles
    jr .doneTiles
    .cityTiles
    COPY_FROM_ROMX DataX_CityTiles_start, DataX_CityTiles_end
    jr .doneTiles
    .farmTiles
    COPY_FROM_ROMX DataX_FarmTiles_start, DataX_FarmTiles_end
    jr .doneTiles
    .spaceTiles
    COPY_FROM_ROMX DataX_SpaceTiles_start, DataX_SpaceTiles_end
    .doneTiles
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
    ld [Ram_AnimationClock_u8], a
    ld [Ram_WalkingCountdown_u8], a
    ld [Ram_WalkingAction_u8], a
    call Func_AnimateTerrain
    ;; Set up animal objects.
    call Func_ClearOam
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
    ;; Initialize music.
    ld hl, Ram_PuzzleState_puzz + PUZZ_Music_song_bptr
    ld a, [hl+]
    ld c, a     ; bank
    ld a, [hl+]
    ld h, [hl]  ; ptr
    ld l, a     ; ptr
    call Func_MusicStart
    ;; Turn on the LCD and fade in.
    call Func_PerformDma
    xor a
    ldh [rSCX], a
    ldh [rSCY], a
    call Func_FadeIn
    ld a, %11010000
    ldh [rOBP1], a
    ;; Run intro dialog.
    ld hl, Ram_PuzzleState_puzz + PUZZ_Intro_dlog_bptr
    call Func_RunDialog
    ;; fall through to Main_PuzzleCommand

Main_PuzzleCommand::
    ld hl, Ram_AnimationClock_u8
    inc [hl]
    call Func_UpdateArrowObjs
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_AnimateTerrain
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
    ld c, BANK(DataX_CannotMove_sfx1)
    ld hl, DataX_CannotMove_sfx1
    call Func_PlaySfx1
    jp Main_PuzzleCommand

;;;=========================================================================;;;

;;; Returns a pointer to the ANIM struct of the currently selected animal.
;;; @return hl A pointer to an ANIM struct.
;;; @preserve bc, de
Func_GetSelectedAnimalPtr_hl:
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
Func_IsSelectedAnimalAlive_fc:
    call Func_GetSelectedAnimalPtr_hl
    ASSERT ANIM_Position_u8 == 0
    ld a, [hl]
    and $0f
    cp TERRAIN_COLS
    ret

;;;=========================================================================;;;

;;; Updates Ram_MoveDirs_u8 for the currently selected animal.
Func_UpdateMoveDirs:
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

;;; Updates the OAMA struct for the currently selected animal.
Func_UpdateSelectedAnimalObjs:
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
Func_SetSelectedAnimalTiles:
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

;;; Updates the X, Y, and TILEID fields for all four Ram_Arrow?_oama objects,
;;; based on the Position/MoveDirs of the currently selected animal.
Func_UpdateArrowObjs:
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
    ld a, [Ram_AnimationClock_u8]
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

Func_AnimateTerrain:
    ld a, [Ram_PuzzleState_puzz + PUZZ_Tileset_u8]
    if_eq TILESET_FARM, jr, _AnimateTerrain_Farm
    if_eq TILESET_OCEAN, jr, _AnimateTerrain_Ocean
    if_eq TILESET_SPACE, jr, _AnimateTerrain_Stars
    ret
_AnimateTerrain_Farm:
    ld a, [Ram_AnimationClock_u8]
    and %01111111
    jr z, .blink
    if_ne 10, ret
    ld a, sizeof_TILE
    .blink
    ldb de, a
    romb BANK(DataX_CowBlinkTiles_tile_arr)
    ld hl, DataX_CowBlinkTiles_tile_arr
    jr _AnimateTerrain_Copy
_AnimateTerrain_Ocean:
    ld a, [Ram_AnimationClock_u8]
    and %00001111
    ret nz
    ld a, [Ram_AnimationClock_u8]
    and %00010000
    ASSERT sizeof_TILE == 16
    ldb de, a
    romb BANK(DataX_OceanTiles_tile_arr)
    ld hl, DataX_OceanTiles_tile_arr
    jr _AnimateTerrain_Copy
_AnimateTerrain_Stars:
    ld a, [Ram_AnimationClock_u8]
    and %00000111
    ASSERT sizeof_TILE == 16
    swap a
    ldb de, a
    romb BANK(DataX_StarsTiles_tile_arr)
    ld hl, DataX_StarsTiles_tile_arr
_AnimateTerrain_Copy:
    add hl, de
    ldw de, hl
    ld bc, sizeof_TILE
    ld hl, Vram_BgTiles + sizeof_TILE * $68
    call Func_MemCopy
    ret

;;;=========================================================================;;;

SECTION "MainAnimalMoving", ROM0

Main_AnimalMoving:
    xor a
    ld [Ram_ArrowN_oama + OAMA_Y], a
    ld [Ram_ArrowS_oama + OAMA_Y], a
    ld [Ram_ArrowE_oama + OAMA_Y], a
    ld [Ram_ArrowW_oama + OAMA_Y], a
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
    call Func_LoadTerrainCellIntoVram
    ;; Play a sound effect.
    ld c, BANK(DataX_PushPipe_sfx4)
    ld hl, DataX_PushPipe_sfx4
    call Func_PlaySfx4
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
    jr _AnimalMoving_RunLoop
    ;; Otherwise, the goat hops at a slower pace.
    .notLeaping
    xor a
    ld [Ram_WalkingAction_u8], a
    ld a, 12
    ld [Ram_WalkingCountdown_u8], a
_AnimalMoving_RunLoop:
    ld hl, Ram_AnimationClock_u8
    inc [hl]
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_AnimateTerrain
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
    ld [de], a
    call Func_LoadTerrainCellIntoVram
    jr .donePushing
    .notPushingEastward
    ;; Check if the animal just finished pushing a pipe westward.
    if_ne ACTF_PUSHW, jr, .notPushingWestward
    dec e
    dec e
    ld a, S_PPW
    ld [de], a
    call Func_LoadTerrainCellIntoVram
    .donePushing
    xor a
    ld [Ram_PipeWL_oama + OAMA_Y], a
    ld [Ram_PipeWR_oama + OAMA_Y], a
    ld [Ram_PipeEL_oama + OAMA_Y], a
    ld [Ram_PipeER_oama + OAMA_Y], a
    jr _AnimalMoving_Update
    .notPushingWestward
_AnimalMoving_TerrainAction:
    ;; Store the terrain type the animal is standing on in a.
    ld a, [de]
    ;; If the animal steps on an arrow, change the value of its ANIM_Facing_u8.
    if_ne S_ARN, jr, .notNorthArrow
    ld [hl], DIRF_NORTH
    jr _AnimalMoving_Update
    .notNorthArrow
    if_ne S_ARS, jr, .notSouthArrow
    ld [hl], DIRF_SOUTH
    jr _AnimalMoving_Update
    .notSouthArrow
    if_ne S_ARE, jr, .notEastArrow
    ld [hl], DIRF_EAST
    jr _AnimalMoving_Update
    .notEastArrow
    if_ne S_ARW, jr, .notWestArrow
    ld [hl], DIRF_WEST
    jr _AnimalMoving_Update
    .notWestArrow
    ;; If the animal steps on a matching teleporter, teleport it.
    if_ne S_TEF, jr, .notElephantTeleporterF
    ld a, [Ram_SelectedAnimal_u8]
    if_ne ANIMAL_ELEPHANT, jr, _AnimalMoving_Update
    ld c, $0f
    jr _AnimalMoving_Teleport
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
    call Func_LoadTerrainCellIntoVram
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
    call Func_GetSelectedAnimalPtr_hl
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
    ld a, SMOKE_PALETTE
    ld [Ram_TeleportL_oama + OAMA_FLAGS], a
    ld [Ram_TeleportR_oama + OAMA_FLAGS], a
    ;; Set the selected animal's position to the teleporter destination.
    ld [hl], b
    call Func_UpdateSelectedAnimalObjs
    ld d, TELEPORT_L3_TILEID
    call Func_SetSelectedAnimalTiles
    ;; Play a sound effect.
    ld c, BANK(DataX_Teleport_sfx4)
    ld hl, DataX_Teleport_sfx4
    call Func_PlaySfx4
    ;; Make the animal vanish.
    xor a
    ld [Ram_SmokeCounter_u8], a
_AnimalMoving_TeleportLoop:
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
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
    call Func_LoadTerrainCellIntoVram
    ;; Play a sound effect.
    ld c, BANK(DataX_Mousetrap_sfx4)
    ld hl, DataX_Mousetrap_sfx4
    call Func_PlaySfx4
    ;; Replace mouse objects with smoke.
    ld d, SMOKE_L1_TILEID
    call Func_SetSelectedAnimalTiles
    xor a
    ld [Ram_SmokeCounter_u8], a
_AnimalMoving_SmokeLoop:
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
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

SECTION "MainVictory", ROM0

Main_Victory:
    ;; TODO: Play victory music, animate animals.
    ;; Run outro dialog.
    ld hl, Ram_PuzzleState_puzz + PUZZ_Outro_dlog_bptr
    call Func_RunDialog
    ;; Fade out and return to world map.
    call Func_FadeOut
    ld c, 1  ; is victory (1=true)
    jp Main_WorldMapScreen

;;;=========================================================================;;;
