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

SECTION "TerrainTable", ROMX, ALIGN[8]

DataX_TerrainTable:
    ;; Open terrain:
    ASSERT @ - DataX_TerrainTable == 4 * O_EMP
    DB $00, $00, $00, $00
    ASSERT @ - DataX_TerrainTable == 4 * O_GRS
    DB $8d, $8d, $8d, $8d
    ASSERT @ - DataX_TerrainTable == 4 * O_BNS
    DB $f4, $f6, $f5, $f7
    ASSERT @ - DataX_TerrainTable == 4 * O_BEW
    DB $f0, $f2, $f1, $f3
    ASSERT @ - DataX_TerrainTable == 4 * O_RMD
    DB $9c, $9e, $9d, $9f
    ASSERT @ - DataX_TerrainTable == 4 * O_RWL
    DB $9c, $a0, $9d, $a1
    ASSERT @ - DataX_TerrainTable == 4 * O_RWR
    DB $a0, $9e, $a1, $9f
    ASSERT @ - DataX_TerrainTable == 4 * O_BST
    DB $78, $7a, $79, $7b
    ;; Goal terrain:
    ASSERT @ - DataX_TerrainTable == 4 * G_PNT
    DB $b0, $b2, $b1, $b3
    ASSERT @ - DataX_TerrainTable == 4 * G_APL
    DB $b4, $b6, $b5, $b7
    ASSERT @ - DataX_TerrainTable == 4 * G_CHS
    DB $b8, $ba, $b9, $bb
    ;; Special terrain:
    ASSERT @ - DataX_TerrainTable == 4 * S_BSH
    DB $74, $76, $75, $77
    ASSERT @ - DataX_TerrainTable == 4 * S_MTP
    DB $7c, $7e, $7d, $7f
    ASSERT @ - DataX_TerrainTable == 4 * S_PPW
    DB $f8, $fa, $f9, $fb
    ASSERT @ - DataX_TerrainTable == 4 * S_PPE
    DB $fc, $fe, $fd, $ff
    ASSERT @ - DataX_TerrainTable == 4 * S_ARN
    DB $6c, $6e, $6c, $6e
    ASSERT @ - DataX_TerrainTable == 4 * S_ARS
    DB $6d, $6f, $6d, $6f
    ASSERT @ - DataX_TerrainTable == 4 * S_ARE
    DB $72, $72, $73, $73
    ASSERT @ - DataX_TerrainTable == 4 * S_ARW
    DB $70, $70, $71, $71
    ASSERT @ - DataX_TerrainTable == 4 * S_TEF
    DB $c0, $c2, $c1, $c3
    ASSERT @ - DataX_TerrainTable == 4 * S_TGE
    DB $c4, $c6, $c5, $c7
    ASSERT @ - DataX_TerrainTable == 4 * S_TMF
    DB $c8, $ca, $c9, $cb
    ;; River terrain:
    ASSERT @ - DataX_TerrainTable == 4 * R_RNS
    DB $e4, $e6, $e5, $e7
    ASSERT @ - DataX_TerrainTable == 4 * R_REW
    DB $e0, $e2, $e1, $e3
    ASSERT @ - DataX_TerrainTable == 4 * R_RNE
    DB $e4, $ee, $e9, $e3
    ASSERT @ - DataX_TerrainTable == 4 * R_RNW
    DB $ec, $e6, $e1, $eb
    ASSERT @ - DataX_TerrainTable == 4 * R_RSE
    DB $e8, $e2, $e5, $ef
    ASSERT @ - DataX_TerrainTable == 4 * R_RSW
    DB $e0, $ea, $ed, $e7
    ;; Mousehole terrain:
    ASSERT @ - DataX_TerrainTable == 4 * M_RNA
    DB $ac, $ae, $ad, $af
    ASSERT @ - DataX_TerrainTable == 4 * M_RNS
    DB $a8, $aa, $a9, $ab
    ASSERT @ - DataX_TerrainTable == 4 * M_FNS
    DB $80, $82, $81, $83
    ASSERT @ - DataX_TerrainTable == 4 * M_BEW
    DB $dc, $de, $dd, $df
    ASSERT @ - DataX_TerrainTable == 4 * M_BNS
    DB $cc, $ce, $cd, $cf
    ;; Wall terrain:
    ASSERT @ - DataX_TerrainTable == 4 * W_RCK
    DB $94, $96, $95, $97
    ASSERT @ - DataX_TerrainTable == 4 * W_FRT
    DB $84, $86, $85, $87
    ASSERT @ - DataX_TerrainTable == 4 * W_FLT
    DB $84, $84, $8f, $85
    ASSERT @ - DataX_TerrainTable == 4 * W_FMD
    DB $84, $84, $85, $85
    ASSERT @ - DataX_TerrainTable == 4 * W_TTP
    DB $88, $8a, $89, $8b
    ASSERT @ - DataX_TerrainTable == 4 * W_TTR
    DB $90, $92, $91, $93
    ASSERT @ - DataX_TerrainTable == 4 * W_TST
    DB $8c, $8e, $89, $8b
    ASSERT @ - DataX_TerrainTable == 4 * W_CSO
    DB $98, $9a, $99, $9b
    ASSERT @ - DataX_TerrainTable == 4 * W_RNS
    DB $a4, $a6, $a5, $a7
    ASSERT @ - DataX_TerrainTable == 4 * W_CRV
    DB $a8, $aa, $a5, $a7
    ASSERT @ - DataX_TerrainTable == 4 * W_RSO
    DB $a4, $a6, $a8, $aa
    ASSERT @ - DataX_TerrainTable == 4 * W_BN1
    DB $d6, $da, $d7, $db
    ASSERT @ - DataX_TerrainTable == 4 * W_BN3
    DB $d8, $d8, $d9, $d9
    ASSERT @ - DataX_TerrainTable == 4 * W_BNE
    DB $d8, $da, $d9, $db
    ASSERT @ - DataX_TerrainTable == 4 * W_BNW
    DB $d6, $d8, $d7, $d9
    ASSERT @ - DataX_TerrainTable == 4 * W_BS1
    DB $d0, $d4, $d1, $d5
    ASSERT @ - DataX_TerrainTable == 4 * W_BS3
    DB $d2, $d2, $d3, $d3
    ASSERT @ - DataX_TerrainTable == 4 * W_BSE
    DB $d2, $d4, $d3, $d5
    ASSERT @ - DataX_TerrainTable == 4 * W_BSW
    DB $d0, $d2, $d1, $d3
    ASSERT @ - DataX_TerrainTable == 4 * W_BEW
    DB $d7, $db, $d7, $db
    ASSERT @ - DataX_TerrainTable == 4 * W_BE3
    DB $d9, $db, $d9, $db
    ASSERT @ - DataX_TerrainTable == 4 * W_BW3
    DB $d7, $d9, $d7, $d9
    ASSERT @ - DataX_TerrainTable == 4 * W_BC4
    DB $d9, $d9, $d9, $d9
    ASSERT @ - DataX_TerrainTable == 4 * W_SNN
    DB $e0, $e2, $bc, $bc
    ASSERT @ - DataX_TerrainTable == 4 * W_SNE
    DB $e0, $ea, $bc, $e7
    ASSERT @ - DataX_TerrainTable == 4 * W_SNW
    DB $e8, $e2, $e5, $bc
    ASSERT @ - DataX_TerrainTable == 4 * W_ONN
    DB $ec, $ee, $bc, $bc
    ASSERT @ - DataX_TerrainTable == 4 * W_ONE
    DB $bc, $ee, $bc, $bc
    ASSERT @ - DataX_TerrainTable == 4 * W_ONW
    DB $ec, $bc, $bc, $bc
    ASSERT @ - DataX_TerrainTable == 4 * W_OOP
    DB $bc, $bc, $bc, $bc
ASSERT @ - DataX_TerrainTable <= 512

;;;=========================================================================;;;

SECTION "TerrainPaletteTable", ROMX, ALIGN[8]

DataX_TerrainPaletteTable:
    ;; Open terrain:
    ASSERT @ - DataX_TerrainPaletteTable == 2 * O_EMP
    DB 7, 7
    ASSERT @ - DataX_TerrainPaletteTable == 2 * O_GRS
    DB 3, 3
    ASSERT @ - DataX_TerrainPaletteTable == 2 * O_BNS
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * O_BEW
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * O_RMD
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * O_RWL
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * O_RWR
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * O_BST
    DB 3, 3
    ;; Goal terrain:
    ASSERT @ - DataX_TerrainPaletteTable == 2 * G_PNT
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * G_APL
    DB 2, 2
    ASSERT @ - DataX_TerrainPaletteTable == 2 * G_CHS
    DB 5, 5
    ;; Special terrain:
    ASSERT @ - DataX_TerrainPaletteTable == 2 * S_BSH
    DB 3, 3
    ASSERT @ - DataX_TerrainPaletteTable == 2 * S_MTP
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * S_PPW
    DB 7, 7
    ASSERT @ - DataX_TerrainPaletteTable == 2 * S_PPE
    DB 7, 7
    ASSERT @ - DataX_TerrainPaletteTable == 2 * S_ARN
    DB 7, 7
    ASSERT @ - DataX_TerrainPaletteTable == 2 * S_ARS
    DB 7, 7
    ASSERT @ - DataX_TerrainPaletteTable == 2 * S_ARE
    DB 7, 7
    ASSERT @ - DataX_TerrainPaletteTable == 2 * S_ARW
    DB 7, 7
    ASSERT @ - DataX_TerrainPaletteTable == 2 * S_TEF
    DB 7, 7
    ASSERT @ - DataX_TerrainPaletteTable == 2 * S_TGE
    DB 7, 7
    ASSERT @ - DataX_TerrainPaletteTable == 2 * S_TMF
    DB 7, 7
    ;; River terrain:
    ASSERT @ - DataX_TerrainPaletteTable == 2 * R_RNS
    DB 4, 4
    ASSERT @ - DataX_TerrainPaletteTable == 2 * R_REW
    DB 4, 4
    ASSERT @ - DataX_TerrainPaletteTable == 2 * R_RNE
    DB 4, 4
    ASSERT @ - DataX_TerrainPaletteTable == 2 * R_RNW
    DB 4, 4
    ASSERT @ - DataX_TerrainPaletteTable == 2 * R_RSE
    DB 4, 4
    ASSERT @ - DataX_TerrainPaletteTable == 2 * R_RSW
    DB 4, 4
    ;; Mousehole terrain:
    ASSERT @ - DataX_TerrainPaletteTable == 2 * M_RNA
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * M_RNS
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * M_FNS
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * M_BEW
    DB 6, 6
    ASSERT @ - DataX_TerrainPaletteTable == 2 * M_BNS
    DB 6, 6
    ;; Wall terrain:
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_RCK
    DB 7, 7
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_FRT
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_FLT
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_FMD
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_TTP
    DB 3, 3
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_TTR
    DB 3, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_TST
    DB 3, 3
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_CSO
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_RNS
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_CRV
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_RSO
    DB 1, 1
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_BN1
    DB 6, 6
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_BN3
    DB 6, 6
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_BNE
    DB 6, 6
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_BNW
    DB 6, 6
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_BS1
    DB 6, 6
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_BS3
    DB 6, 6
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_BSE
    DB 6, 6
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_BSW
    DB 6, 6
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_BEW
    DB 6, 6
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_BE3
    DB 6, 6
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_BW3
    DB 6, 6
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_BC4
    DB 6, 6
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_SNN
    DB 4, 4
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_SNE
    DB 4, 4
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_SNW
    DB 4, 4
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_ONN
    DB 4, 4
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_ONE
    DB 4, 4
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_ONW
    DB 4, 4
    ASSERT @ - DataX_TerrainPaletteTable == 2 * W_OOP
    DB 4, 4
ASSERT @ - DataX_TerrainPaletteTable <= 256

;;;=========================================================================;;;

SECTION "TerrainFunctions", ROM0

;;; @param de A pointer to a terrain cell in a 256-byte-aligned PUZZ struct.
Func_LoadTerrainCellIntoVram::
    romb BANK(DataX_TerrainTable)
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
    ASSERT LOW(DataX_TerrainTable) == 0
    ld a, HIGH(DataX_TerrainTable)
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
    ;; Load terrain tile IDs into the BG tile map.
    ld e, 0
    push de
    romb BANK(DataX_TerrainTable)
    ld hl, Vram_BgMap
    REPT TERRAIN_ROWS
    call Func_LoadTerrainRow
    ENDR
    pop de
    ;; If color is disabled, we're done.
    ldh a, [Hram_ColorEnabled_bool]
    or a
    ret z
    ;; Load terrain color palette numbers into the BG tile map.
    ld a, 1
    ldh [rVBK], a
    romb BANK(DataX_TerrainPaletteTable)
    ld hl, Vram_BgMap
    REPT TERRAIN_ROWS
    call Func_LoadTerrainPaletteRow
    ENDR
    xor a
    ldh [rVBK], a
    ret

;;; @prereq ROM bank is set to BANK(DataX_TerrainTable).
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
    ASSERT LOW(DataX_TerrainTable) == 0
    ld a, HIGH(DataX_TerrainTable)
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
    ASSERT LOW(DataX_TerrainTable) == 0
    ld a, HIGH(DataX_TerrainTable)
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

;;; @prereq ROM bank is set to BANK(DataX_TerrainPaletteTable).
;;; @param de Pointer to start of Ram_PuzzleState_puzz row.
;;; @param hl Pointer to start of Vram_BgMap row.
;;; @return de Pointer to start of next Ram_PuzzleState_puzz row.
;;; @return hl Pointer to start of next Vram_BgMap row.
Func_LoadTerrainPaletteRow:
    ;; Fill in the top row of VRAM tiles.
    .topLoop
    ld a, [de]
    inc e
    rlca
    ld c, a
    ASSERT LOW(DataX_TerrainPaletteTable) == 0
    ld b, HIGH(DataX_TerrainPaletteTable)
    ld a, [bc]
    ld [hl+], a
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
    ld c, a
    ASSERT LOW(DataX_TerrainPaletteTable) == 0
    ld b, HIGH(DataX_TerrainPaletteTable)
    inc c
    ld a, [bc]
    ld [hl+], a
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
