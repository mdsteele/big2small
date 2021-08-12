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
INCLUDE "src/tileset.inc"

;;;=========================================================================;;;

BRICK_START    EQU $e0
BRIDGE_START   EQU $c0
FENCE_START    EQU $d0
GOAL_START     EQU $80
HOUSE_START    EQU $f0
LAUNCH_START   EQU $c0
MOUNTAIN_START EQU $d0
PEBBLE_START   EQU $cc
PIPE_START     EQU $8c
SHORE_START    EQU $b0
TELEPORT_START EQU $94
TREE_START     EQU $a0

D_TERR: MACRO
    STATIC_ASSERT _NARG == 6
ANI = ANIMATED_TILEID - (\6)
EMP = $00 - (\6)
    ASSERT @ - DataX_TerrainTable == 4 * (\1)
    DB (\2) + (\6), (\3) + (\6), (\4) + (\6), (\5) + (\6)
ENDM

D_PAL: MACRO
    STATIC_ASSERT _NARG >= 2 && _NARG <= 3
    ASSERT @ - DataX_TerrainPaletteTable == 2 * (\1)
    IF _NARG < 3
    DB (\2), (\2)
    ELSE
    DB (\2), (\3)
    ENDC
ENDM

;;;=========================================================================;;;

SECTION "TerrainTable", ROMX, ALIGN[8]

DataX_TerrainTable:
    ;; Open terrain:
    D_TERR O_EMP, $00, $00, $00, $00, 0
    D_TERR O_GRS, $05, $05, $05, $05, TREE_START
    D_TERR O_PEB, $00, $02, $01, $03, PEBBLE_START
    D_TERR O_BNS, $04, $06, $05, $07, BRIDGE_START
    D_TERR O_BEW, $00, $02, $01, $03, BRIDGE_START
    D_TERR O_RMD, $04, $06, $05, $07, MOUNTAIN_START
    D_TERR O_RWL, $04, $08, $05, $09, MOUNTAIN_START
    D_TERR O_RWR, $08, $06, $09, $07, MOUNTAIN_START
    D_TERR O_BST, $78, $7a, $79, $7b, 0
    D_TERR O_CE3, EMP, $0e, EMP, $0f, MOUNTAIN_START
    D_TERR O_CW3, $0c, EMP, $0d, EMP, MOUNTAIN_START
    ;; Goal terrain:
    D_TERR G_PNT, $00, $02, $01, $03, GOAL_START + $00
    D_TERR G_APL, $00, $02, $01, $03, GOAL_START + $04
    D_TERR G_CHS, $00, $02, $01, $03, GOAL_START + $08
    ;; Special terrain:
    D_TERR S_BSH, $74, $76, $75, $77, 0
    D_TERR S_MTP, $7c, $7e, $7d, $7f, 0
    D_TERR S_PPW, $00, $02, $01, $03, PIPE_START + $00
    D_TERR S_PPE, $00, $02, $01, $03, PIPE_START + $04
    D_TERR S_ARN, $6c, $6e, $6c, $6e, 0
    D_TERR S_ARS, $6d, $6f, $6d, $6f, 0
    D_TERR S_ARE, $72, $72, $73, $73, 0
    D_TERR S_ARW, $70, $70, $71, $71, 0
    D_TERR S_TEF, $00, $02, $01, $03, TELEPORT_START + $00
    D_TERR S_TGE, $00, $02, $01, $03, TELEPORT_START + $04
    D_TERR S_TME, $00, $02, $01, $03, TELEPORT_START + $08
    D_TERR S_TMF, $00, $02, $01, $03, TELEPORT_START + $08
    ;; River terrain:
    D_TERR R_KS3, $0a, $0a, $1d, $1f, MOUNTAIN_START
    D_TERR R_KSE, $1c, $22, $1d, $23, MOUNTAIN_START
    D_TERR R_KSW, $20, $1e, $21, $1f, MOUNTAIN_START
    D_TERR R_KW3, $20, $0a, $20, $0a, MOUNTAIN_START
    D_TERR R_KOP, $0a, $0a, $0a, $0a, MOUNTAIN_START
    D_TERR R_KST, $0a, $0a, $0a, $1c, MOUNTAIN_START
    D_TERR R_RNS, $04, $06, $05, $07, SHORE_START
    D_TERR R_REW, $00, $02, $01, $03, SHORE_START
    D_TERR R_RNE, $04, $0e, $09, $03, SHORE_START
    D_TERR R_RNW, $0c, $06, $01, $0b, SHORE_START
    D_TERR R_RSE, $08, $02, $05, $0f, SHORE_START
    D_TERR R_RSW, $00, $0a, $0d, $07, SHORE_START
    D_TERR R_RS1, $08, $0a, $05, $07, SHORE_START
    D_TERR R_SN3, $00, $02, ANI, ANI, SHORE_START
    D_TERR R_SNE, $00, $0a, ANI, $07, SHORE_START
    D_TERR R_SNW, $08, $02, $05, ANI, SHORE_START
    D_TERR R_SS3, ANI, ANI, $01, $03, SHORE_START
    D_TERR R_SSE, ANI, $06, $01, $0b, SHORE_START
    D_TERR R_SSW, $04, ANI, $09, $03, SHORE_START
    D_TERR R_ONN, $0c, $0e, ANI, ANI, SHORE_START
    D_TERR R_OSS, ANI, ANI, $0d, $0f, SHORE_START
    D_TERR R_ONE, ANI, $0e, ANI, ANI, SHORE_START
    D_TERR R_ONW, $0c, ANI, ANI, ANI, SHORE_START
    D_TERR R_OOP, ANI, ANI, ANI, ANI, SHORE_START
    D_TERR R_EDG, $00, $02, ANI, ANI, SHORE_START
    D_TERR R_GRT, $01, $03, ANI, ANI, SHORE_START
    D_TERR R_GDR, $00, $00, ANI, ANI, SHORE_START
    ;; Mousehole terrain:
    D_TERR M_RNA, $14, $16, $15, $17, MOUNTAIN_START
    D_TERR M_FNS, $00, $02, $01, $03, FENCE_START
    D_TERR M_BNS, $00, $02, $01, $03, BRICK_START
    ;; Wall terrain:
    D_TERR W_RCK, $0c, $0e, $0d, $0f, TREE_START
    D_TERR W_COW, ANI, $6a, $69, $6b, 0
    D_TERR W_DMP, $00, $02, $01, $03, BRICK_START
    D_TERR W_FE1, $04, $06, $05, $07, FENCE_START
    D_TERR W_FE3, $09, $0f, $08, $0e, FENCE_START
    D_TERR W_FW1, $04, $04, $13, $05, FENCE_START
    D_TERR W_FW3, $0d, $0b, $0c, $0a, FENCE_START
    D_TERR W_FNS, $04, $04, $05, $05, FENCE_START
    D_TERR W_FNE, $06, EMP, $08, $0e, FENCE_START
    D_TERR W_FNW, EMP, $04, $0c, $0a, FENCE_START
    D_TERR W_FSE, $09, $0f, $07, EMP, FENCE_START
    D_TERR W_FSW, $0d, $0b, EMP, $13, FENCE_START
    D_TERR W_FEW, $10, $12, $10, $12, FENCE_START
    D_TERR W_HNE, $08, $0c, $09, $0d, HOUSE_START
    D_TERR W_HNW, $00, $04, $01, $05, HOUSE_START
    D_TERR W_HSE, $0a, $0e, $0b, $0f, HOUSE_START
    D_TERR W_HSW, $02, $06, $03, $07, HOUSE_START
    D_TERR W_TTP, $00, $02, $01, $03, TREE_START
    D_TERR W_TTR, $08, $0a, $09, $0b, TREE_START
    D_TERR W_TST, $04, $06, $01, $03, TREE_START
    D_TERR W_CS1, $10, $12, $11, $13, MOUNTAIN_START
    D_TERR W_CS3, $00, $02, $01, $03, MOUNTAIN_START
    D_TERR W_CSE, $00, $12, $01, $13, MOUNTAIN_START
    D_TERR W_CSW, $10, $02, $11, $03, MOUNTAIN_START
    D_TERR W_CEW, $0c, $0e, $0d, $0f, MOUNTAIN_START
    D_TERR W_CE1, $00, $1a, $01, $1b, MOUNTAIN_START
    D_TERR W_CE3, EMP, $0e, EMP, $0f, MOUNTAIN_START
    D_TERR W_CW1, $18, $02, $19, $03, MOUNTAIN_START
    D_TERR W_CW3, $0c, EMP, $0d, EMP, MOUNTAIN_START
    D_TERR W_BS1, $00, $04, $01, $05, BRICK_START + $04
    D_TERR W_BS3, $02, $02, $03, $03, BRICK_START + $04
    D_TERR W_BSE, $02, $04, $03, $05, BRICK_START + $04
    D_TERR W_BSW, $00, $02, $01, $03, BRICK_START + $04
    D_TERR W_BE1, $02, $0f, $03, $05, BRICK_START + $04
    D_TERR W_BW1, $0d, $02, $01, $03, BRICK_START + $04
    D_TERR W_LNS, $08, $08, $0c, $0c, BRICK_START + $04
    D_TERR W_LN1, $06, $0a, $07, $0b, BRICK_START + $04
    D_TERR W_LN3, $08, $08, $09, $09, BRICK_START + $04
    D_TERR W_LNE, $08, $0a, $09, $0b, BRICK_START + $04
    D_TERR W_LNW, $06, $08, $07, $09, BRICK_START + $04
    D_TERR W_LS1, $07, $0b, $0d, $0f, BRICK_START + $04
    D_TERR W_LS3, $09, $09, $0c, $0c, BRICK_START + $04
    D_TERR W_LSE, $09, $0b, $0c, $0f, BRICK_START + $04
    D_TERR W_LSW, $07, $09, $0d, $0c, BRICK_START + $04
    D_TERR W_LEW, $07, $0b, $07, $0b, BRICK_START + $04
    D_TERR W_LE1, $08, $0a, $0c, $0f, BRICK_START + $04
    D_TERR W_LE3, $09, $0b, $09, $0b, BRICK_START + $04
    D_TERR W_LEC, $0c, $0b, $09, $0b, BRICK_START + $04
    D_TERR W_LW1, $06, $08, $0d, $0c, BRICK_START + $04
    D_TERR W_LW3, $07, $09, $07, $09, BRICK_START + $04
    D_TERR W_LWC, $07, $0e, $07, $09, BRICK_START + $04
    D_TERR W_LLE, $10, $0b, $0c, $0f, BRICK_START + $04
    D_TERR W_LC4, $06, $0a, $0d, $0f, BRICK_START + $04
    D_TERR W_ROP, $09, $09, $09, $09, BRICK_START + $04
    D_TERR W_PNW, EMP, EMP, $15, $1c, BRICK_START
    D_TERR W_PSW, $18, $12, $19, $1d, BRICK_START
    D_TERR W_PNE, EMP, EMP, $1c, $17, BRICK_START
    D_TERR W_PSE, $12, $1a, $1d, $1b, BRICK_START
    D_TERR W_PNR, $00, $03, $01, $04, LAUNCH_START
    D_TERR W_PSR, $02, $05, $3d, $3d, LAUNCH_START
    D_TERR W_PNT, $06, $09, $07, $0a, LAUNCH_START
    D_TERR W_PST, $08, $0b, $3d, $3d, LAUNCH_START
ASSERT @ - DataX_TerrainTable <= 512

;;;=========================================================================;;;

SECTION "TerrainPaletteTable", ROMX, ALIGN[8]

DataX_TerrainPaletteTable:
    ;; Open terrain:
    D_PAL O_EMP, 7
    D_PAL O_GRS, 3
    D_PAL O_PEB, 7
    D_PAL O_BNS, 1
    D_PAL O_BEW, 1
    D_PAL O_RMD, 6
    D_PAL O_RWL, 6
    D_PAL O_RWR, 6
    D_PAL O_BST, 3
    D_PAL O_CE3, 6
    D_PAL O_CW3, 6
    ;; Goal terrain:
    D_PAL G_PNT, 1
    D_PAL G_APL, 2
    D_PAL G_CHS, 5
    ;; Special terrain:
    D_PAL S_BSH, 3
    D_PAL S_MTP, 1
    D_PAL S_PPW, 7
    D_PAL S_PPE, 7
    D_PAL S_ARN, 7
    D_PAL S_ARS, 7
    D_PAL S_ARE, 7
    D_PAL S_ARW, 7
    D_PAL S_TEF, 7
    D_PAL S_TGE, 7
    D_PAL S_TME, 7
    D_PAL S_TMF, 7
    ;; River terrain:
    D_PAL R_KS3, 6
    D_PAL R_KSE, 6
    D_PAL R_KSW, 6
    D_PAL R_KW3, 6
    D_PAL R_KOP, 6
    D_PAL R_KST, 6
    D_PAL R_RNS, 4
    D_PAL R_REW, 4
    D_PAL R_RNE, 4
    D_PAL R_RNW, 4
    D_PAL R_RSE, 4
    D_PAL R_RSW, 4
    D_PAL R_RS1, 4
    D_PAL R_SN3, 4
    D_PAL R_SNE, 4
    D_PAL R_SNW, 4
    D_PAL R_SS3, 4
    D_PAL R_SSE, 4
    D_PAL R_SSW, 4
    D_PAL R_ONN, 4
    D_PAL R_OSS, 4
    D_PAL R_ONE, 4
    D_PAL R_ONW, 4
    D_PAL R_OOP, 4
    D_PAL R_EDG, 6, 4
    D_PAL R_GRT, 6, 4
    D_PAL R_GDR, 7, 4
    ;; Mousehole terrain:
    D_PAL M_RNA, 6
    D_PAL M_FNS, 1
    D_PAL M_BNS, 6
    ;; Wall terrain:
    D_PAL W_RCK, 7
    D_PAL W_COW, 6
    D_PAL W_DMP, 6
    D_PAL W_FE1, 1
    D_PAL W_FE3, 1
    D_PAL W_FW1, 1
    D_PAL W_FW3, 1
    D_PAL W_FNS, 1
    D_PAL W_FNE, 1
    D_PAL W_FNW, 1
    D_PAL W_FSE, 1
    D_PAL W_FSW, 1
    D_PAL W_FEW, 1
    D_PAL W_HNE, 6
    D_PAL W_HNW, 6
    D_PAL W_HSE, 6
    D_PAL W_HSW, 6
    D_PAL W_TTP, 3
    D_PAL W_TTR, 3, 1
    D_PAL W_TST, 3
    D_PAL W_CS1, 6
    D_PAL W_CS3, 6
    D_PAL W_CSE, 6
    D_PAL W_CSW, 6
    D_PAL W_CEW, 6
    D_PAL W_CE1, 6
    D_PAL W_CE3, 6
    D_PAL W_CW1, 6
    D_PAL W_CW3, 6
    D_PAL W_BS1, 6
    D_PAL W_BS3, 6
    D_PAL W_BSE, 6
    D_PAL W_BSW, 6
    D_PAL W_BE1, 6
    D_PAL W_BW1, 6
    D_PAL W_LNS, 6
    D_PAL W_LN1, 6
    D_PAL W_LN3, 6
    D_PAL W_LNE, 6
    D_PAL W_LNW, 6
    D_PAL W_LS1, 6
    D_PAL W_LS3, 6
    D_PAL W_LSE, 6
    D_PAL W_LSW, 6
    D_PAL W_LEW, 6
    D_PAL W_LE1, 6
    D_PAL W_LE3, 6
    D_PAL W_LEC, 6
    D_PAL W_LW1, 6
    D_PAL W_LW3, 6
    D_PAL W_LWC, 6
    D_PAL W_LLE, 6
    D_PAL W_LC4, 6
    D_PAL W_ROP, 6
    D_PAL W_PNW, 6
    D_PAL W_PSW, 6
    D_PAL W_PNE, 6
    D_PAL W_PSE, 6
    D_PAL W_PNR, 7
    D_PAL W_PSR, 7, 6
    D_PAL W_PNT, 6
    D_PAL W_PST, 6
ASSERT @ - DataX_TerrainPaletteTable <= 256

;;;=========================================================================;;;

SECTION "TerrainFunctions", ROM0

;;; @param de A pointer to a terrain cell in a 256-byte-aligned PUZZ struct.
Func_LoadTerrainCellIntoVram::
    romb BANK(DataX_TerrainTable)
    ;; Make hl point to the VRAM tile for the top-left quarter of the square.
    ld a, e
    and $f0
    mult 2
    ld c, a
    ld a, 0
    rla
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
    mult 4
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
    if_dmg ret
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
    mult 4
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
    mult 4
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
    mult 2
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
    mult 2
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
