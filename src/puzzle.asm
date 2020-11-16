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
INCLUDE "src/puzzle.inc"

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
    xor a
    ld [rSCX], a
    ld [rSCY], a
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
