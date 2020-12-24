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

SECTION "TerrainTable", ROM0, ALIGN[8]

Data_TerrainTable:
    ;; Open terrain:
    ASSERT @ - Data_TerrainTable == 4 * O_EMP
    DB $20, $20, $20, $20
    ASSERT @ - Data_TerrainTable == 4 * O_GRS
    DB $8d, $8d, $8d, $8d
    ASSERT @ - Data_TerrainTable == 4 * O_BNS
    DB $f4, $f6, $f5, $f7
    ASSERT @ - Data_TerrainTable == 4 * O_BEW
    DB $f0, $f2, $f1, $f3
    ASSERT @ - Data_TerrainTable == 4 * O_RMD
    DB $9c, $9e, $9d, $9f
    ASSERT @ - Data_TerrainTable == 4 * O_RWL
    DB $9c, $a0, $9d, $a1
    ASSERT @ - Data_TerrainTable == 4 * O_RWR
    DB $a0, $9e, $a1, $9f
    ASSERT @ - Data_TerrainTable == 4 * O_BST
    DB $18, $1a, $19, $1b
    ;; Goal terrain:
    ASSERT @ - Data_TerrainTable == 4 * G_PNT
    DB $00, $02, $01, $03
    ASSERT @ - Data_TerrainTable == 4 * G_APL
    DB $04, $06, $05, $07
    ASSERT @ - Data_TerrainTable == 4 * G_CHS
    DB $08, $0a, $09, $0b
    ;; Special terrain:
    ASSERT @ - Data_TerrainTable == 4 * S_BSH
    DB $14, $16, $15, $17
    ASSERT @ - Data_TerrainTable == 4 * S_PPW
    DB $f8, $fa, $f9, $fb
    ASSERT @ - Data_TerrainTable == 4 * S_PPE
    DB $fc, $fe, $fd, $ff
    ASSERT @ - Data_TerrainTable == 4 * S_ARN
    DB $0c, $0e, $0c, $0e
    ASSERT @ - Data_TerrainTable == 4 * S_ARS
    DB $0d, $0f, $0d, $0f
    ASSERT @ - Data_TerrainTable == 4 * S_ARE
    DB $12, $12, $13, $13
    ASSERT @ - Data_TerrainTable == 4 * S_ARW
    DB $10, $10, $11, $11
    ;; River terrain:
    ASSERT @ - Data_TerrainTable == 4 * R_RNS
    DB $e4, $e6, $e5, $e7
    ASSERT @ - Data_TerrainTable == 4 * R_REW
    DB $e0, $e2, $e1, $e3
    ASSERT @ - Data_TerrainTable == 4 * R_RNE
    DB $e4, $ee, $e9, $e3
    ASSERT @ - Data_TerrainTable == 4 * R_RNW
    DB $ec, $e6, $e1, $eb
    ASSERT @ - Data_TerrainTable == 4 * R_RSE
    DB $e8, $e2, $e5, $ef
    ASSERT @ - Data_TerrainTable == 4 * R_RSW
    DB $e0, $ea, $ed, $e7
    ;; Mousehole terrain:
    ASSERT @ - Data_TerrainTable == 4 * M_RNA
    DB $ac, $ae, $ad, $af
    ASSERT @ - Data_TerrainTable == 4 * M_RNS
    DB $a8, $aa, $a9, $ab
    ;; Wall terrain:
    ASSERT @ - Data_TerrainTable == 4 * W_RCK
    DB $80, $82, $81, $83
    ASSERT @ - Data_TerrainTable == 4 * W_FRT
    DB $84, $86, $85, $87
    ASSERT @ - Data_TerrainTable == 4 * W_FLT
    DB $84, $84, $8f, $85
    ASSERT @ - Data_TerrainTable == 4 * W_FMD
    DB $84, $84, $85, $85
    ASSERT @ - Data_TerrainTable == 4 * W_TTP
    DB $88, $8a, $89, $8b
    ASSERT @ - Data_TerrainTable == 4 * W_TTR
    DB $90, $92, $91, $93
    ASSERT @ - Data_TerrainTable == 4 * W_TST
    DB $8c, $8e, $89, $8b
    ASSERT @ - Data_TerrainTable == 4 * W_BLD
    DB $94, $96, $95, $97
    ASSERT @ - Data_TerrainTable == 4 * W_CSO
    DB $98, $9a, $99, $9b
    ASSERT @ - Data_TerrainTable == 4 * W_RNS
    DB $a4, $a6, $a5, $a7
    ASSERT @ - Data_TerrainTable == 4 * W_CRV
    DB $a8, $aa, $a5, $a7
    ASSERT @ - Data_TerrainTable == 4 * W_RSO
    DB $a4, $a6, $a8, $aa
    ASSERT @ - Data_TerrainTable == 4 * W_BN1
    DB $c6, $ca, $c7, $cb
    ASSERT @ - Data_TerrainTable == 4 * W_BN3
    DB $c8, $c8, $c9, $c9
    ASSERT @ - Data_TerrainTable == 4 * W_BNE
    DB $c8, $ca, $c9, $cb
    ASSERT @ - Data_TerrainTable == 4 * W_BNW
    DB $c6, $c8, $c7, $c9
    ASSERT @ - Data_TerrainTable == 4 * W_BS1
    DB $c0, $c4, $c1, $c5
    ASSERT @ - Data_TerrainTable == 4 * W_BS3
    DB $c2, $c2, $c3, $c3
    ASSERT @ - Data_TerrainTable == 4 * W_BSE
    DB $c2, $c4, $c3, $c5
    ASSERT @ - Data_TerrainTable == 4 * W_BSW
    DB $c0, $c2, $c1, $c3
    ASSERT @ - Data_TerrainTable == 4 * W_BEW
    DB $c7, $cb, $c7, $cb
    ASSERT @ - Data_TerrainTable == 4 * W_BE3
    DB $c9, $cb, $c9, $cb
    ASSERT @ - Data_TerrainTable == 4 * W_BW3
    DB $c7, $c9, $c7, $c9
    ASSERT @ - Data_TerrainTable == 4 * W_BC4
    DB $c9, $c9, $c9, $c9
ASSERT @ - Data_TerrainTable <= 512

;;;=========================================================================;;;

SECTION "TerrainFunctions", ROM0

;;; @param de A pointer to a terrain cell in a 256-byte-aligned PUZZ struct.
Func_LoadTerrainCellIntoVram::
    ;; Make hl point to the VRAM tile for the top-left quarter of the square.
    ld a, e
    and $f0
    rla
    ld c, a
    ld a, 0
    adc 0
    ld b, a
    ld a, e
    and $0f
    or c
    ld c, a
    ld hl, Vram_BgMap
    add hl, bc
    add hl, bc
    ;; Make bc point to the start of the terrain table entry.
    ld a, [de]
    rlca
    sla a
    ld c, a
    ASSERT LOW(Data_TerrainTable) == 0
    ld a, HIGH(Data_TerrainTable)
    adc 0
    ld b, a
    ;; Set the VRAM tiles for the top half of the square.
    ld a, [bc]
    ld [hl+], a
    inc c
    ld a, [bc]
    ld [hl+], a
    inc c
    ;; Set the VRAM tiles for the bottom half of the square.
    ld de, SCRN_VX_B - 2
    add hl, de
    ld a, [bc]
    ld [hl+], a
    inc c
    ld a, [bc]
    ld [hl], a
    ret

;;; @param d High byte of pointer to 256-byte-aligned PUZZ struct.
Func_LoadPuzzleTerrainIntoVram::
    ld e, 0
    ld hl, Vram_BgMap
    REPT TERRAIN_ROWS
    call Func_LoadTerrainRow
    ENDR
    ret

;;; @param de Pointer to start of Ram_PuzzleState_puzz row.
;;; @param hl Pointer to start of Vram_BgMap row.
;;; @return de Pointer to start of next Ram_PuzzleState_puzz row.
;;; @return hl Pointer to start of next Vram_BgMap row.
Func_LoadTerrainRow:
    ;; Fill in the top row of VRAM tiles.
    .topLoop
    ld a, [de]
    inc e
    rlca
    sla a
    ld c, a
    ASSERT LOW(Data_TerrainTable) == 0
    ld a, HIGH(Data_TerrainTable)
    adc 0
    ld b, a
    ld a, [bc]
    ld [hl+], a
    inc c
    ld a, [bc]
    ld [hl+], a
    ld a, l
    and %00011111
    if_ne 2 * TERRAIN_COLS, jr, .topLoop
    ;; Set up for the bottom row.
    ld bc, SCRN_VX_B - (2 * TERRAIN_COLS)
    add hl, bc
    ld a, e
    and %11110000
    ld e, a
    ;; Fill in the bottom row of VRAM tiles.
    .botLoop
    ld a, [de]
    inc e
    rlca
    sla a
    ld c, a
    ASSERT LOW(Data_TerrainTable) == 0
    ld a, HIGH(Data_TerrainTable)
    adc 0
    ld b, a
    inc c
    inc c
    ld a, [bc]
    ld [hl+], a
    inc c
    ld a, [bc]
    ld [hl+], a
    ld a, l
    and %00011111
    if_ne 2 * TERRAIN_COLS, jr, .botLoop
    ;; Set up return values
    ld bc, SCRN_VX_B - (2 * TERRAIN_COLS)
    add hl, bc
    ld a, e
    add (16 - TERRAIN_COLS)
    ld e, a
    ret

;;;=========================================================================;;;
