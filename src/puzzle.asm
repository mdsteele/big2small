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

;;; TODO: tiles for elephant
ELEPHANT_SL1_TILEID EQU 0
ELEPHANT_NL1_TILEID EQU 8
ELEPHANT_WL1_TILEID EQU 16

;;; TODO: tiles for goat
GOAT_SL1_TILEID EQU 0
GOAT_NL1_TILEID EQU 8
GOAT_WL1_TILEID EQU 16

MOUSE_SL1_TILEID EQU 0
MOUSE_NL1_TILEID EQU 8
MOUSE_WL1_TILEID EQU 16

ARROW_NS_TILEID EQU 24
STOP_NS_TILEID  EQU 26
ARROW_EW_TILEID EQU 28
STOP_EW_TILEID  EQU 30

;;;=========================================================================;;;

SECTION "PuzzleState", WRAM0

;;; The ANIM structs for each of the three animals.
Ram_Elephant_anim:
    DS sizeof_ANIM
Ram_Goat_anim:
    DS sizeof_ANIM
Ram_Mouse_anim:
    DS sizeof_ANIM

;;; This should be set to one of the ANIMAL_* constants.
Ram_SelectedAnimal_u8:
    DB

;;; MoveDirs: A bitfield indicating in which directions the currently-selected
;;;   animal can move.  This uses the DIRB_* and DIRF_* constants.
Ram_MoveDirs_u8:
    DB

;;; A counter that is incremented once per frame and that can be used to drive
;;; looping animations.
Ram_AnimationClock_u8:
    DB

;;; How far forward from its current position the selected animal has moved.
Ram_MovedPixels_u8:
    DB

;;;=========================================================================;;;

SECTION "MainPuzzleScreen", ROM0

;;; @prereq LCD is off.
Main_PuzzleScreen::
    ld hl, Data_Puzzle0_puzz
    ;; Load terrain map.
    push hl
    ld d, h
    ld e, l
    ld hl, Vram_BgMap
    REPT TERRAIN_ROWS
    call Func_LoadTerrainRow
    ENDR
    ;; Initialize state.
    pop hl
    ld bc, PUZZ_StartE_u8
    add hl, bc
    ld a, [hl+]
    ld [Ram_Elephant_anim + ANIM_Position_u8], a
    ld a, [hl+]
    ld [Ram_Goat_anim + ANIM_Position_u8], a
    ld a, [hl]
    ld [Ram_Mouse_anim + ANIM_Position_u8], a
    ld a, DIRF_SOUTH
    ld [Ram_Elephant_anim + ANIM_Facing_u8], a
    ld [Ram_Goat_anim + ANIM_Facing_u8], a
    ld [Ram_Mouse_anim + ANIM_Facing_u8], a
    xor a
    ld [Ram_AnimationClock_u8], a
    ld [Ram_MovedPixels_u8], a
    ;; Set up animal objects.
    call Func_ClearOam
    ld a, ANIMAL_ELEPHANT
    ld [Ram_SelectedAnimal_u8], a
    call Func_UpdateSelectedAnimalObjs
    ld a, ANIMAL_MOUSE
    ld [Ram_SelectedAnimal_u8], a
    call Func_UpdateSelectedAnimalObjs
    ld a, ANIMAL_GOAT
    ld [Ram_SelectedAnimal_u8], a
    call Func_UpdateSelectedAnimalObjs
    ;; Set up arrow objects.
    ld a, OAMF_PAL1
    ld [Ram_ArrowN_oama + OAMA_FLAGS], a
    ld [Ram_ArrowE_oama + OAMA_FLAGS], a
    ld a, OAMF_PAL1 | OAMF_XFLIP
    ld [Ram_ArrowW_oama + OAMA_FLAGS], a
    ld a, OAMF_PAL1 | OAMF_YFLIP
    ld [Ram_ArrowS_oama + OAMA_FLAGS], a
    call Func_GetSelectedAnimalPtr_hl
    call Func_UpdateMoveDirs
    ;; Initialize music.
    ld c, BANK(Data_TitleMusic_song)
    ld hl, Data_TitleMusic_song
    call Func_MusicStart
    ;; Turn on the LCD and fade in.
    xor a
    ld [rSCX], a
    ld [rSCY], a
    call Func_FadeIn
    ld a, %11100000
    ldh [rOBP1], a
_PuzzleScreen_RunLoop:
    ld hl, Ram_AnimationClock_u8
    inc [hl]
    call Func_UpdateArrowObjs
    call Func_MusicUpdate
    call Func_WaitForVBlankAndPerformDma
    call Func_UpdateButtonState
    ld a, [Ram_ButtonsPressed_u8]
    ld b, a
_PuzzleScreen_HandleButtonStart:
    bit PADB_START, b
    jr z, .noPress
    ;; TODO: pause the game
    .noPress
_PuzzleScreen_HandleButtonA:
    bit PADB_A, b
    jr z, .noPress
    ld a, [Ram_SelectedAnimal_u8]
    inc a
    if_lt 3, jr, .noOverflow
    xor a
    .noOverflow
    jr _PuzzleScreen_SelectAnimal
    .noPress
_PuzzleScreen_HandleButtonB:
    bit PADB_B, b
    jr z, .noPress
    ld a, [Ram_SelectedAnimal_u8]
    sub 1
    jr nc, .noUnderflow
    ld a, 2
    .noUnderflow
    jr _PuzzleScreen_SelectAnimal
    .noPress
_PuzzleScreen_HandleButtonUp:
    bit PADB_UP, b
    jr z, .noPress
    ld d, DIRF_NORTH
    jr _PuzzleScreen_TryMove
    .noPress
_PuzzleScreen_HandleButtonDown:
    bit PADB_DOWN, b
    jr z, .noPress
    ld d, DIRF_SOUTH
    jr _PuzzleScreen_TryMove
    .noPress
_PuzzleScreen_HandleButtonLeft:
    bit PADB_LEFT, b
    jr z, .noPress
    ld d, DIRF_WEST
    jr _PuzzleScreen_TryMove
    .noPress
_PuzzleScreen_HandleButtonRight:
    bit PADB_RIGHT, b
    jr z, _PuzzleScreen_RunLoop
    ld d, DIRF_EAST
    jr _PuzzleScreen_TryMove

_PuzzleScreen_SelectAnimal:
    ld [Ram_SelectedAnimal_u8], a
    call Func_GetSelectedAnimalPtr_hl
    call Func_UpdateMoveDirs
    jr _PuzzleScreen_RunLoop

_PuzzleScreen_TryMove:
    ;; Check if we can move in the DIRF_* direction that's stored in d.
    ld a, [Ram_MoveDirs_u8]
    and d
    jr z, _PuzzleScreen_CannotMove
    ;; We can move, so store d in ANIM_Facing_u8 and switch to AnimalMoving
    ;; mode.
    call Func_GetSelectedAnimalPtr_hl  ; preserves d
    ASSERT ANIM_Facing_u8 == 1
    inc hl
    ld a, d
    ld [hl], a
    jp Main_AnimalMoving

_PuzzleScreen_CannotMove:
    ld a, %00101101
    ldh [rAUD1SWEEP], a
    ld a, %10010000
    ldh [rAUD1LEN], a
    ld a, %11000010
    ldh [rAUD1ENV], a
    ld a, %11000000
    ldh [rAUD1LOW], a
    ld a, %10000111
    ldh [rAUD1HIGH], a
    jp _PuzzleScreen_RunLoop

;;;=========================================================================;;;

;;; Returns a pointer to the ANIM struct of the currently selected animal.
;;; @return hl A pointer to an ANIM struct.
;;; @preserve bc, de
Func_GetSelectedAnimalPtr_hl:
    ld a, [Ram_SelectedAnimal_u8]
    if_eq ANIMAL_MOUSE, jr, .mouseSelected
    if_eq ANIMAL_GOAT, jr, .goatSelected
    .elephantSelected
    ld hl, Ram_Elephant_anim
    ret
    .goatSelected
    ld hl, Ram_Goat_anim
    ret
    .mouseSelected
    ld hl, Ram_Mouse_anim
    ret

;;; @param c The position to check
;;; @return z True if there's an animal at that position.
;;; @preserve bc, de, hl
Func_IsAnimalAt_z:
    ld a, [Ram_Elephant_anim + ANIM_Position_u8]
    cp c
    ret z
    ld a, [Ram_Goat_anim + ANIM_Position_u8]
    cp c
    ret z
    ld a, [Ram_Mouse_anim + ANIM_Position_u8]
    cp c
    ret

;;;=========================================================================;;;

;;; Updates Ram_MoveDirs_u8 for a given ANIM struct.
;;; @param hl A pointer to an ANIM struct.
Func_UpdateMoveDirs:
    ASSERT ANIM_Position_u8 == 0
    ld c, [hl]
    ld b, DIRF_NORTH | DIRF_SOUTH | DIRF_EAST | DIRF_WEST
    ld hl, Data_Puzzle0_puzz
    ld d, 0
    ld e, c
    add hl, de
_UpdateMoveDirs_West:
    ;; Check if we're on the west edge of the screen.
    ld a, c
    and $0f
    jr nz, .noEdge
    res DIRB_WEST, b
    jr .done
    .noEdge
    ;; If not, then check if there's a wall to the west.
    dec hl
    ld a, [hl+]
    if_lt $30, jr, .noWall
    res DIRB_WEST, b
    jr .done
    .noWall
    ;; If not, then check if there's another animal to the west.
    dec c
    call Func_IsAnimalAt_z  ; preserves bc and hl
    jr nz, .noAnim
    res DIRB_WEST, b
    .noAnim
    inc c
    .done
_UpdateMoveDirs_East:
    ;; Check if we're on the east edge of the screen.
    ld a, c
    and $0f
    if_lt (TERRAIN_COLS - 1), jr, .noEdge
    res DIRB_EAST, b
    jr .done
    .noEdge
    ;; If not, then check if there's a wall to the east.
    inc hl
    ld a, [hl-]
    if_lt $30, jr, .noWall
    res DIRB_EAST, b
    jr .done
    .noWall
    ;; If not, then check if there's another animal to the east.
    inc c
    call Func_IsAnimalAt_z  ; preserves bc and hl
    jr nz, .noAnim
    res DIRB_EAST, b
    .noAnim
    dec c
    .done
_UpdateMoveDirs_North:
    ;; Check if we're on the north edge of the screen.
    ld a, c
    and $f0
    jr nz, .noEdge
    res DIRB_NORTH, b
    jr .done
    .noEdge
    ;; If not, then check if there's a wall to the north.
    ld de, -16
    add hl, de
    ld a, [hl]
    ld de, 16
    add hl, de
    if_lt $30, jr, .noWall
    res DIRB_NORTH, b
    jr .done
    .noWall
    ;; If not, then check if there's another animal to the north.
    ld a, c
    sub 16
    ld c, a
    call Func_IsAnimalAt_z  ; preserves bc and hl
    jr nz, .noAnim
    res DIRB_NORTH, b
    .noAnim
    ld a, c
    add 16
    ld c, a
    .done
_UpdateMoveDirs_South:
    ;; Check if we're on the south edge of the screen.
    ld a, c
    and $f0
    if_lt (16 * (TERRAIN_ROWS - 1)), jr, .noEdge
    res DIRB_SOUTH, b
    jr .done
    .noEdge
    ;; If not, then check if there's a wall to the south.
    ld de, 16
    add hl, de
    ld a, [hl]
    if_lt $30, jr, .noWall
    res DIRB_SOUTH, b
    jr .done
    .noWall
    ;; If not, then check if there's another animal to the south.
    ld a, c
    add 16
    ld c, a
    call Func_IsAnimalAt_z  ; preserves bc
    jr nz, .noAnim
    res DIRB_SOUTH, b
    .noAnim
    .done
_UpdateMoveDirs_Finish:
    ld a, b
    ld [Ram_MoveDirs_u8], a
    ret

;;;=========================================================================;;;

;;; Updates the OAMA struct for the currently selected animal.
;;; @preserve hl
Func_UpdateSelectedAnimalObjs:
    ld a, [Ram_SelectedAnimal_u8]
    if_eq ANIMAL_MOUSE, jp, _UpdateSelectedAnimalObjs_Mouse
    if_eq ANIMAL_GOAT, jp, _UpdateSelectedAnimalObjs_Goat
_UpdateSelectedAnimalObjs_Elephant:
    ld a, [Ram_MovedPixels_u8]
    ld c, a
    ld a, [Ram_Elephant_anim + ANIM_Facing_u8]
    ld b, a
_UpdateSelectedAnimalObjs_ElephantYPosition:
    ld a, [Ram_Elephant_anim + ANIM_Position_u8]
    and $f0
    add 16
    bit DIRB_NORTH, b
    jr z, .notNorth
    sub c
    jr .notSouth
    .notNorth
    bit DIRB_SOUTH, b
    jr z, .notSouth
    add c
    .notSouth
    ld [Ram_ElephantL_oama + OAMA_Y], a
    ld [Ram_ElephantR_oama + OAMA_Y], a
_UpdateSelectedAnimalObjs_ElephantXPosition:
    ld a, [Ram_Elephant_anim + ANIM_Position_u8]
    and $0f
    swap a
    add 8
    bit DIRB_WEST, b
    jr z, .notWest
    sub c
    jr .notEast
    .notWest
    bit DIRB_EAST, b
    jr z, .notEast
    add c
    .notEast
    ld [Ram_ElephantL_oama + OAMA_X], a
    add 8
    ld [Ram_ElephantR_oama + OAMA_X], a
_UpdateSelectedAnimalObjs_ElephantTileAndFlags:
    ld a, c
    and %00000100
    bit DIRB_EAST, b
    jr z, .notEast
    add ELEPHANT_WL1_TILEID
    ld [Ram_ElephantR_oama + OAMA_TILEID], a
    add 2
    ld [Ram_ElephantL_oama + OAMA_TILEID], a
    ld a, OAMF_XFLIP
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
    xor a
    ld [Ram_ElephantL_oama + OAMA_FLAGS], a
    ld [Ram_ElephantR_oama + OAMA_FLAGS], a
    ret

_UpdateSelectedAnimalObjs_Goat:
    ld a, [Ram_MovedPixels_u8]
    ld c, a
    ld a, [Ram_Goat_anim + ANIM_Facing_u8]
    ld b, a
_UpdateSelectedAnimalObjs_GoatYPosition:
    ld a, [Ram_Goat_anim + ANIM_Position_u8]
    and $f0
    add 16
    bit DIRB_NORTH, b
    jr z, .notNorth
    sub c
    jr .notSouth
    .notNorth
    bit DIRB_SOUTH, b
    jr z, .notSouth
    add c
    .notSouth
    ld [Ram_GoatL_oama + OAMA_Y], a
    ld [Ram_GoatR_oama + OAMA_Y], a
_UpdateSelectedAnimalObjs_GoatXPosition:
    ld a, [Ram_Goat_anim + ANIM_Position_u8]
    and $0f
    swap a
    add 8
    bit DIRB_WEST, b
    jr z, .notWest
    sub c
    jr .notEast
    .notWest
    bit DIRB_EAST, b
    jr z, .notEast
    add c
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
    ld a, OAMF_XFLIP
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
    xor a
    ld [Ram_GoatL_oama + OAMA_FLAGS], a
    ld [Ram_GoatR_oama + OAMA_FLAGS], a
    ret

_UpdateSelectedAnimalObjs_Mouse:
    ld a, [Ram_MovedPixels_u8]
    ld c, a
    ld a, [Ram_Mouse_anim + ANIM_Facing_u8]
    ld b, a
_UpdateSelectedAnimalObjs_MouseYPosition:
    ld a, [Ram_Mouse_anim + ANIM_Position_u8]
    and $f0
    add 16
    bit DIRB_NORTH, b
    jr z, .notNorth
    sub c
    jr .notSouth
    .notNorth
    bit DIRB_SOUTH, b
    jr z, .notSouth
    add c
    .notSouth
    ld [Ram_MouseL_oama + OAMA_Y], a
    ld [Ram_MouseR_oama + OAMA_Y], a
_UpdateSelectedAnimalObjs_MouseXPosition:
    ld a, [Ram_Mouse_anim + ANIM_Position_u8]
    and $0f
    swap a
    add 8
    bit DIRB_WEST, b
    jr z, .notWest
    sub c
    jr .notEast
    .notWest
    bit DIRB_EAST, b
    jr z, .notEast
    add c
    .notEast
    ld [Ram_MouseL_oama + OAMA_X], a
    add 8
    ld [Ram_MouseR_oama + OAMA_X], a
_UpdateSelectedAnimalObjs_MouseTileAndFlags:
    ld a, c
    and %00000100
    bit DIRB_EAST, b
    jr z, .notEast
    add MOUSE_WL1_TILEID
    ld [Ram_MouseR_oama + OAMA_TILEID], a
    add 2
    ld [Ram_MouseL_oama + OAMA_TILEID], a
    ld a, OAMF_XFLIP
    ld [Ram_MouseL_oama + OAMA_FLAGS], a
    ld [Ram_MouseR_oama + OAMA_FLAGS], a
    ret
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
    xor a
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

;;; @param de Pointer to start of terrain row.
;;; @param hl Pointer to start of VRAM tile map row.
;;; @return de Pointer to start of next terrain row.
;;; @return hl Pointer to start of next VRAM tile map row.
Func_LoadTerrainRow:
    ;; Fill in the top row of VRAM tiles.
    .topLoop
    ld a, [de]
    inc de
    rlca
    rlca
    ASSERT LOW(Data_TerrainTable_start) == 0
    ld b, HIGH(Data_TerrainTable_start)
    ld c, a
    ld a, [bc]
    ld [hl+], a
    inc c
    ld a, [bc]
    ld [hl+], a
    ld a, l
    and %00011111
    cp 2 * TERRAIN_COLS
    jr nz, .topLoop
    ;; Set up for the bottom row.
    ld bc, SCRN_VX_B - (2 * TERRAIN_COLS)
    add hl, bc
    ld a, e
    and %11110000
    ld e, a
    ;; Fill in the bottom row of VRAM tiles.
    .botLoop
    ld a, [de]
    inc de
    rlca
    rlca
    add 2
    ASSERT LOW(Data_TerrainTable_start) == 0
    ld b, HIGH(Data_TerrainTable_start)
    ld c, a
    ld a, [bc]
    ld [hl+], a
    inc c
    ld a, [bc]
    ld [hl+], a
    ld a, l
    and %00011111
    cp 2 * TERRAIN_COLS
    jr nz, .botLoop
    ;; Set up return values
    ld bc, SCRN_VX_B - (2 * TERRAIN_COLS)
    add hl, bc
    ld a, e
    add (16 - TERRAIN_COLS)
    ld e, a
    ld a, d
    adc 0
    ld d, a
    ret

;;;=========================================================================;;;

SECTION "TerrainTable", ROM0, ALIGN[8]

Data_TerrainTable_start:
    ;; Open:
    DB $20, $20, $20, $20
    DB $8d, $8d, $8d, $8d
    DB $20, $20, $20, $20
    DB $20, $20, $20, $20
    ;; Goals:
    DB $00, $02, $01, $03  ; Peanut
    DB $04, $06, $05, $07  ; Apple
    DB $08, $0a, $09, $0b  ; Cheese
    ;; TODO:
    DS 4 * 41
    ;; Walls:
    DB $80, $82, $81, $83  ; nsew
    DB $84, $86, $85, $87  ; nseW
    DB $84, $84, $8f, $85  ; nsEw
    DB $84, $84, $85, $85  ; nsEW
    DB $88, $8a, $89, $8b  ; nSew
    DB $3c, $3c, $3c, $3c  ; nSeW
    DB $3c, $3c, $3c, $3c  ; nSEw
    DB $3c, $3c, $3c, $3c  ; nSEW
    DB $90, $92, $91, $93  ; Nsew
    DB $3c, $3c, $3c, $3c  ; NseW
    DB $3c, $3c, $3c, $3c  ; NsEw
    DB $3c, $3c, $3c, $3c  ; NsEW
    DB $8c, $8e, $89, $8b  ; NSew
    DB $3c, $3c, $3c, $3c  ; NSeW
    DB $3c, $3c, $3c, $3c  ; NSEw
    DB $3c, $3c, $3c, $3c  ; NSEW

;;;=========================================================================;;;

SECTION "MainAnimalMoving", ROM0

Main_AnimalMoving:
    xor a
    ld [Ram_ArrowN_oama + OAMA_Y], a
    ld [Ram_ArrowS_oama + OAMA_Y], a
    ld [Ram_ArrowE_oama + OAMA_Y], a
    ld [Ram_ArrowW_oama + OAMA_Y], a
    ld [Ram_MovedPixels_u8], a
_AnimalMoving_RunLoop:
    ld hl, Ram_AnimationClock_u8
    inc [hl]
    call Func_MusicUpdate
    call Func_WaitForVBlankAndPerformDma
    ld a, [Ram_MovedPixels_u8]
    add 2
    if_eq 16, jr, _AnimalMoving_ChangePosition
    ld [Ram_MovedPixels_u8], a
    call Func_UpdateSelectedAnimalObjs
    jr _AnimalMoving_RunLoop

_AnimalMoving_ChangePosition:
    xor a
    ld [Ram_MovedPixels_u8], a
    ;; Store selected animal's ANIM_Facing_u8 in a, and ANIM ptr in hl.
    call Func_GetSelectedAnimalPtr_hl
    ASSERT ANIM_Facing_u8 == 1
    inc hl
    ld a, [hl-]
    push af
    ;; Move the animal forward by one square, updating its ANIM_Position_u8.
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
    ASSERT ANIM_Position_u8 == 0
    ld a, [hl]
    add d
    ld [hl], a
    call Func_UpdateSelectedAnimalObjs  ; preserves hl
    ;; Check if we can keep going.
    call Func_UpdateMoveDirs
    pop de
    ld a, [Ram_MoveDirs_u8]
    and d
    jr nz, _AnimalMoving_RunLoop
_AnimalMoving_DoneMoving:
    ;; TODO: Check if all animals are now at their goals
    jp _PuzzleScreen_RunLoop

;;;=========================================================================;;;
