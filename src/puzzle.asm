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

;;;=========================================================================;;;

TERRAIN_COLS EQU 10
TERRAIN_ROWS EQU 9

;;;=========================================================================;;;

;;; PUZZ: Describes a puzzle.  PUZZ structs must be aligned to 16 bytes.
RSRESET
;;; StartE: Specifies the start position of the elephant.  The high nibble
;;;   gives the X position (0-9) and the low nibble gives the Y position (0-8).
PUZZ_StartE_u8 EQU (TERRAIN_COLS + 0)
;;; StartG: Specifies the start position of the goat, encoded as above.
PUZZ_StartG_u8 EQU (TERRAIN_COLS + 1)
;;; StartM: Specifies the start position of the mouse, encoded as above.
PUZZ_StartM_u8 EQU (TERRAIN_COLS + 2)
sizeof_PUZZ    EQU (16 * TERRAIN_ROWS)

;;;=========================================================================;;;

SECTION "MainPuzzle", ROM0

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
    ;; Set up objects.
    call Func_ClearOam
    pop hl
    ld bc, PUZZ_StartM_u8
    add hl, bc
    ld e, [hl]
    ld a, e
    and $0f
    swap a
    add 16
    ld [Ram_MouseL_oama + OAMA_Y], a
    ld [Ram_MouseR_oama + OAMA_Y], a
    ld a, e
    and $f0
    add 8
    ld [Ram_MouseL_oama + OAMA_X], a
    add 8
    ld [Ram_MouseR_oama + OAMA_X], a
    ld a, 16
    ld [Ram_MouseR_oama + OAMA_TILEID], a
    add 2
    ld [Ram_MouseL_oama + OAMA_TILEID], a
    ld a, OAMF_XFLIP
    ld [Ram_MouseL_oama + OAMA_FLAGS], a
    ld [Ram_MouseR_oama + OAMA_FLAGS], a
    ;; Initialize music.
    ld c, BANK(Data_TitleMusic_song)
    ld hl, Data_TitleMusic_song
    call Func_MusicStart
    ;; Turn on the LCD and fade in.
    call Func_FadeIn
_PuzzleScreen_RunLoop:
    call Func_MusicUpdate
    call Func_WaitForVblankAndPerformDma
    jr _PuzzleScreen_RunLoop

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
    DB 0, 0, 0, 0
    DB 1, 1, 1, 1
    DB 4, 6, 5, 7

;;;=========================================================================;;;
