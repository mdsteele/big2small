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
INCLUDE "src/save.inc"

;;;=========================================================================;;;

PUZZLE_NODE_TILEID EQU $82

;;;=========================================================================;;;

SECTION "WorldMapFunctions", ROM0

;;; @prereq LCD is off.
;;; @param c 1 if current puzzle was just solved, 0 otherwise.
Main_WorldMapScreen::
    ;; If the current puzzle was just solved, mark it as solved and the next
    ;; puzzle as unlocked.
    bit 0, c
    jr z, .notSolved
    ld hl, Ram_Progress_file + FILE_CurrentPuzzleNumber_u8
    ld e, [hl]
    ld d, 0
    inc [hl]
    ld hl, Ram_Progress_file + FILE_PuzzleStatus_u8_arr
    add hl, de
    bit STATB_SOLVED, [hl]
    jr nz, .alreadySolved
    set STATB_SOLVED, [hl]
    ld a, [Ram_Progress_file + FILE_NumSolvedPuzzles_bcd8]
    add 1
    daa
    ld [Ram_Progress_file + FILE_NumSolvedPuzzles_bcd8], a
    .alreadySolved
    inc hl
    set STATB_UNLOCKED, [hl]
    call Func_SaveFile
    .notSolved
    ;; Copy the tile data to VRAM.
    ld hl, Vram_SharedTiles  ; dest
    COPY_FROM_ROMX DataX_MapTiles_start, DataX_MapTiles_end
    ;; Copy the BG tile map to VRAM.
    ld hl, Vram_BgMap  ; dest
    COPY_FROM_ROMX DataX_WorldTileMap_start, DataX_WorldTileMap_end
    ;; TODO: Draw map paths between unlocked puzzles.
_WorldMapScreen_DrawUnlockedNodes:
    ASSERT LOW(Ram_Progress_file + FILE_PuzzleStatus_u8_arr) == 0
    ld de, Ram_Progress_file + FILE_PuzzleStatus_u8_arr
    .puzzLoop
    ;; Check if puzzle number e is unlocked.
    ld a, [de]
    bit STATB_UNLOCKED, a
    jr z, .locked
    ;; Make hl point to the position entry for puzzle number e.
    ld b, 0
    ld c, e
    sla c
    ASSERT NUM_PUZZLES * 2 < $100
    ld hl, Data_PuzzleMapPositions_u8_pair_arr
    add hl, bc
    ;; Load position row into a and col into c.
    ld a, [hl+]
    ld c, [hl]
    ;; Make hl point to the VRAM BG map cell for the position.
    rlca
    swap a
    ld b, a
    and %00000011
    add HIGH(Vram_BgMap)
    ld h, a
    ld a, b
    and %11100000
    ASSERT LOW(Vram_BgMap) == 0
    add c
    ld l, a
    ;; Draw the puzzle node into VRAM.
    ld [hl], PUZZLE_NODE_TILEID
    ;; Move on to check the next puzzle.
    .locked
    inc e
    ld a, e
    if_lt NUM_PUZZLES, jr, .puzzLoop
_WorldMapScreen_SetUpObjects:
    ;; Set up objects.
    call Func_ClearOam
    ;; TODO: Set up objects for walking around the map.
    ;; Initialize music.
    ld c, BANK(DataX_RestYe_song)
    ld hl, DataX_RestYe_song
    call Func_MusicStart
    ;; Turn on the LCD and fade in.
    call Func_ScrollMapToCurrentPuzzle
    call Func_PerformDma
    call Func_FadeIn
_WorldMapScreen_RunLoop:
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_UpdateButtonState
    ld a, [Ram_ButtonsPressed_u8]
    bit PADB_START, a
    jr z, _WorldMapScreen_RunLoop
_WorldMapScreen_StartNextPuzzle:
    call Func_FadeOut
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    ld c, a  ; current puzzle number
    jp Main_BeginPuzzle

;;;=========================================================================;;;

;;; Set rSCX and rSCY to try to center the current puzzle node on the screen,
;;; while clamping the camera position.
Func_ScrollMapToCurrentPuzzle:
    ;; Make hl point to the current puzzle's position entry.
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    ASSERT NUM_PUZZLES * 2 < $100
    rlca
    add LOW(Data_PuzzleMapPositions_u8_pair_arr)
    ld l, a
    ld a, HIGH(Data_PuzzleMapPositions_u8_pair_arr)
    adc 0
    ld h, a
_ScrollMapToCurrentPuzzle_ScrollY:
    ;; Store row * 8 + 4 into a.
    ld a, [hl+]
    swap a
    rrca
    add 4
    ;; Clamp the camera Y position.
    if_ge SCRN_Y / 2, jr, .notLow
    xor a
    jr .setPos
    .notLow
    if_lt SCRN_VY - SCRN_Y / 2, jr, .notHigh
    ld a, SCRN_VY - SCRN_Y
    jr .setPos
    .notHigh
    sub SCRN_Y / 2
    .setPos
    ldh [rSCY], a
_ScrollMapToCurrentPuzzle_ScrollX:
    ;; Store col * 8 + 4 into a.
    ld a, [hl]
    swap a
    rrca
    add 4
    ;; Clamp the camera X position.
    if_ge SCRN_X / 2, jr, .notLow
    xor a
    jr .setPos
    .notLow
    if_lt SCRN_VX - SCRN_X / 2, jr, .notHigh
    ld a, SCRN_VX - SCRN_X
    jr .setPos
    .notHigh
    sub SCRN_X / 2
    .setPos
    ldh [rSCX], a
    ret

;;;=========================================================================;;;
