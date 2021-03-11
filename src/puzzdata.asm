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

INCLUDE "src/color.inc"
INCLUDE "src/puzzle.inc"
INCLUDE "src/save.inc"
INCLUDE "src/tileset.inc"

;;;=========================================================================;;;

D_BPTR: MACRO
    DB BANK(\1), LOW(\1), HIGH(\1), (\2), (\3), (\4)
ENDM

;;;=========================================================================;;;

SECTION "PuzzlePtrs", ROMX

;;; An array that maps from puzzle numbers to pointers to PUZZ structs stored
;;; in BANK("PuzzleData").
DataX_Puzzles_puzz_ptr_arr::
    DW DataX_Forest1_puzz
    DW DataX_Forest2_puzz
    DW DataX_Forest3_puzz
    DW DataX_Bush1_puzz
    DW DataX_Farm1_puzz
    DW DataX_Farm2_puzz
    DW DataX_Farm3_puzz
    DW DataX_Mountain1_puzz
    DW DataX_Seaside1_puzz
    DW DataX_Seaside2_puzz
    DW DataX_Sewer1_puzz
    DW DataX_Sewer2_puzz
    DW DataX_City1_puzz
    DW DataX_City2_puzz
    DW DataX_Space1_puzz
    DW DataX_Space2_puzz
    DW DataX_Space3_puzz
ASSERT @ - DataX_Puzzles_puzz_ptr_arr == 2 * NUM_PUZZLES

;;;=========================================================================;;;

SECTION "PuzzleData", ROMX

DataX_Forest1_puzz:
    .begin
    DB W_TST, W_TTR, W_TTR, O_GRS, W_TTR, W_TTR, O_EMP, W_TTR, W_TST, W_TST
    DB $17, DIRF_WEST, 0, 0, 0, 0
    DB W_TST, G_PNT, O_EMP, O_EMP, O_GRS, O_EMP, O_EMP, O_EMP, W_TST, W_TST
    DB $71, DIRF_SOUTH, 0, 0, 0, 0
    DB W_TST, W_TTP, W_FW1, W_FNS, W_FE1, O_EMP, W_FW1, W_FE1, W_TTR, W_TST
    DB $58, DIRF_SOUTH, 0, 0, 0, 0
    DB W_TST, W_TTR, W_RCK, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, G_CHS, W_TST
    D_BPTR DataX_TitleMusic_song, 0, 0, 0
    DB W_TST, W_FW1, W_FE1, O_EMP, W_FW1, W_FNS, W_FNS, W_FNS, W_FE1, W_TST
    D_BPTR DataX_Intro_dlog, 0, 0, 0
    DB W_TST, O_GRS, O_GRS, O_EMP, O_EMP, O_EMP, G_APL, W_TTP, O_EMP, W_TST
    D_BPTR DataX_Outro_dlog, 0, 0, 0
    DB W_TST, O_GRS, O_EMP, O_EMP, O_GRS, O_EMP, W_RCK, W_TTR, O_GRS, W_TST
    DB TILESET_FARM, COLORSET_SPRING, 0, 0, 0, 0
    DB W_TST, O_EMP, W_TTP, O_GRS, O_EMP, O_EMP, O_EMP, O_GRS, O_GRS, W_TST
    DS 6
    DB W_TST, W_TTP, W_TST, W_TTP, W_TTP, O_EMP, O_EMP, W_TTP, W_TTP, W_TST
ASSERT @ - .begin == sizeof_PUZZ

DataX_Forest2_puzz:
    .begin
    DB W_TST, W_TST, W_TST, W_TST, O_GRS, W_TTR, W_TST, W_TTR, W_TST, W_TST
    DB $63, DIRF_EAST, 0, 0, 0, 0
    DB W_TST, W_TST, W_TTR, W_TTR, O_EMP, O_EMP, W_TTR, O_EMP, W_TST, W_TST
    DB $62, DIRF_EAST, 0, 0, 0, 0
    DB W_TST, W_TST, W_FW1, W_FNS, W_FNS, W_FNS, W_FNS, W_FE1, W_TTR, W_TST
    DB $61, DIRF_EAST, 0, 0, 0, 0
    DB W_TST, W_TTR, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, W_RCK, O_EMP, W_TTR
    D_BPTR DataX_RestYe_song, 0, 0, 0
    DB W_TST, W_TTP, W_TST, O_EMP, O_GRS, O_GRS, O_EMP, O_EMP, W_TTP, W_TTP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB W_TST, W_TTR, W_TTR, W_RCK, O_EMP, O_GRS, O_EMP, W_RCK, W_TTR, W_TST
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB W_TST, O_GRS, O_EMP, O_EMP, O_GRS, O_EMP, G_PNT, G_APL, G_CHS, W_TST
    DB TILESET_FARM, COLORSET_SUMMER, 0, 0, 0, 0
    DB W_TTR, O_EMP, W_TTP, W_TTP, O_EMP, O_EMP, W_TTP, W_TTP, W_TTP, W_TST
    DS 6
    DB W_TTP, O_EMP, W_TTR, W_TST, W_TTP, W_TTP, W_TST, W_TST, W_TST, W_TST
ASSERT @ - .begin == sizeof_PUZZ

DataX_Forest3_puzz:
    .begin
    DB W_TST, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TST
    DB $11, DIRF_EAST, 0, 0, 0, 0
    DB W_TTR, O_GRS, O_EMP, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, W_TST
    DB $20, DIRF_EAST, 0, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, O_EMP, O_GRS, O_EMP, O_EMP, W_TST
    DB $31, DIRF_EAST, 0, 0, 0, 0
    DB W_TTP, O_GRS, O_GRS, O_EMP, O_EMP, W_TTP, O_EMP, O_EMP, W_RCK, W_TST
    D_BPTR DataX_TitleMusic_song, 0, 0, 0
    DB W_TTR, W_TTP, W_FW1, W_FNS, W_FE1, W_TTR, W_RCK, O_EMP, O_GRS, W_TST
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB W_TTP, W_TTR, O_EMP, O_EMP, G_PNT, O_EMP, O_EMP, O_GRS, O_GRS, W_TST
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB W_TST, O_GRS, G_APL, O_EMP, O_EMP, W_FW1, W_FNS, W_FNS, W_FE1, W_TST
    DB TILESET_FARM, COLORSET_AUTUMN, 0, 0, 0, 0
    DB W_TST, O_GRS, O_GRS, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, G_CHS, W_TST
    DS 6
    DB W_TST, W_TTP, O_GRS, W_TST, W_TTP, W_TTP, W_TTP, W_TTP, W_TTP, W_TST
ASSERT @ - .begin == sizeof_PUZZ

DataX_Bush1_puzz:
    .begin
    DB O_EMP, O_EMP, W_TTR, W_TTR, W_TTR, O_EMP, O_GRS, W_TTR, W_TST, W_TTR
    DB $13, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, S_BSH, O_EMP, O_EMP, S_BSH, O_EMP, O_EMP, O_GRS, W_TTR, O_GRS
    DB $00, DIRF_EAST, 0, 0, 0, 0
    DB O_GRS, W_RCK, O_EMP, W_RCK, W_TTP, W_TTP, O_EMP, O_EMP, S_BSH, O_EMP
    DB $12, DIRF_SOUTH, 0, 0, 0, 0
    DB W_FNS, W_FNS, W_FNS, W_FE1, W_TTR, W_TTR, O_EMP, O_EMP, W_TTP, O_EMP
    D_BPTR DataX_TitleMusic_song, 0, 0, 0
    DB O_EMP, O_EMP, G_APL, O_EMP, O_EMP, O_EMP, O_EMP, W_TTP, W_TTR, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB W_TTP, W_FNS, W_FE1, S_BSH, W_FW1, W_FNS, W_FE1, W_TTR, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB W_TTR, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_BSH, O_EMP, O_EMP
    DB TILESET_FARM, COLORSET_WINTER, 0, 0, 0, 0
    DB O_GRS, O_EMP, O_EMP, G_CHS, W_RCK, O_EMP, O_EMP, W_TTP, G_PNT, O_EMP
    DS 6
    DB W_TTP, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, W_TTP, W_TST, W_TTP, W_TTP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Farm1_puzz:
    .begin
    DB W_HNW, W_HNE, O_GRS, O_GRS, O_EMP, W_TTR, W_TTR, O_EMP, O_GRS, O_GRS
    DB $20, DIRF_EAST, 0, 0, 0, 0
    DB W_HSW, W_HSE, O_EMP, G_PNT, O_EMP, O_EMP, G_CHS, O_EMP, O_EMP, O_GRS
    DB $67, DIRF_WEST, 0, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    DB $80, DIRF_SOUTH, 0, 0, 0, 0
    DB W_FNW, W_FNS, W_FNS, W_FNS, W_FNS, W_FNS, M_FNS, W_FNS, W_FNE, O_EMP
    D_BPTR DataX_RestYe_song, 0, 0, 0
    DB W_FSE, W_COW, O_GRS, O_GRS, O_GRS, O_GRS, O_EMP, O_GRS, W_FEW, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB O_GRS, O_GRS, O_EMP, O_GRS, O_GRS, G_APL, O_GRS, O_GRS, W_FEW, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB W_FNS, W_FNS, M_FNS, W_FNE, O_GRS, W_COW, O_GRS, O_GRS, W_FEW, O_EMP
    DB TILESET_FARM, COLORSET_SPRING, 0, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, W_FSW, W_FNS, W_FNS, W_FNS, W_FNS, W_FSE, O_GRS
    DS 6
    DB O_GRS, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, O_GRS, O_GRS
ASSERT @ - .begin == sizeof_PUZZ

DataX_Farm2_puzz:
    .begin
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, G_APL, O_EMP, O_EMP
    DB $66, DIRF_SOUTH, 0, 0, 0, 0
    DB W_TTP, O_EMP, O_EMP, W_TTP, O_EMP, O_GRS, O_GRS, O_EMP, O_EMP, O_EMP
    DB $19, DIRF_WEST, 0, 0, 0, 0
    DB W_TTR, O_EMP, S_BSH, W_TST, W_FW1, W_FNS, W_FNS, W_FNS, M_FNS, W_FNS
    DB $60, DIRF_EAST, 0, 0, 0, 0
    DB O_EMP, O_GRS, O_EMP, W_TTR, O_EMP, O_EMP, O_GRS, O_EMP, O_EMP, O_GRS
    D_BPTR DataX_RestYe_song, 0, 0, 0
    DB O_EMP, O_EMP, O_GRS, O_GRS, O_GRS, W_COW, O_EMP, O_GRS, S_BSH, O_GRS
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB W_FNS, M_FNS, W_FNS, W_FNS, W_FNS, W_FNS, W_FNS, W_FNE, O_EMP, O_GRS
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, W_HNW, W_HNE, O_EMP, O_GRS, W_FSW, M_FNS, W_FNS
    DB TILESET_FARM, COLORSET_SUMMER, 0, 0, 0, 0
    DB O_EMP, O_EMP, G_CHS, W_HSW, W_HSE, G_PNT, O_EMP, O_EMP, O_EMP, O_EMP
    DS 6
    DB O_GRS, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, O_GRS, W_COW
ASSERT @ - .begin == sizeof_PUZZ

DataX_Farm3_puzz:
    .begin
    DB O_GRS, O_GRS, O_EMP, O_EMP, W_COW, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    DB $80, DIRF_EAST, 0, 0, 0, 0
    DB O_GRS, W_FNW, W_FE1, O_EMP, O_EMP, O_EMP, O_EMP, W_HNW, W_HNE, O_EMP
    DB $49, DIRF_WEST, 0, 0, 0, 0
    DB O_GRS, W_FEW, O_GRS, O_EMP, O_EMP, O_EMP, G_APL, W_HSW, W_HSE, O_EMP
    DB $00, DIRF_SOUTH, 0, 0, 0, 0
    DB O_GRS, W_FW3, W_FNS, M_FNS, W_FE1, O_EMP, O_GRS, O_GRS, O_GRS, O_EMP
    D_BPTR DataX_RestYe_song, 0, 0, 0
    DB O_GRS, W_FEW, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, O_EMP, O_GRS
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB O_GRS, W_FEW, O_EMP, G_CHS, O_EMP, W_FNW, W_FNS, W_FNS, W_FNS, W_FNS
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB O_GRS, W_FEW, O_EMP, O_EMP, O_EMP, W_FEW, O_GRS, G_PNT, O_GRS, W_COW
    DB TILESET_FARM, COLORSET_AUTUMN, 0, 0, 0, 0
    DB O_GRS, W_FSW, W_FE1, O_EMP, W_COW, W_FSW, M_FNS, W_FE1, O_EMP, W_TTP
    DS 6
    DB O_GRS, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_TTR
ASSERT @ - .begin == sizeof_PUZZ

DataX_Mountain1_puzz:
    .begin
    DB O_EMP, O_EMP, O_EMP, O_EMP, W_TTR, S_ARS, O_EMP, O_EMP, S_ARW, W_TTR
    DB $89, DIRF_SOUTH, 0, 0, 0, 0
    DB W_CS3, O_CW3, O_EMP, O_EMP, S_ARW, O_EMP, O_EMP, O_EMP, O_EMP, G_CHS
    DB $12, DIRF_EAST, 0, 0, 0, 0
    DB O_GRS, W_CSW, W_CS3, O_RMD, W_CS3, M_RNA, W_CS3, O_RWL, O_RWR, W_CS3
    DB $07, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, O_EMP, G_APL, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_CE3, W_CS3
    D_BPTR DataX_TitleMusic_song, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, W_RCK, O_EMP, O_EMP, O_CE3, W_CS3, W_CSE, O_GRS
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_CW1, W_CSE, O_GRS, O_EMP, S_ARS
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB O_RMD, W_CE1, O_EMP, O_EMP, O_GRS, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP
    DB TILESET_MOUNTAIN, COLORSET_SUMMER, 0, 0, 0, 0
    DB O_EMP, G_PNT, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS
    DS 6
    DB O_GRS, O_GRS, O_EMP, O_GRS, S_ARN, O_EMP, S_ARE, O_EMP, O_GRS, O_GRS
ASSERT @ - .begin == sizeof_PUZZ

DataX_Seaside1_puzz:
    .begin
    DB W_TTP, W_TTR, O_EMP, R_RNS, O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP
    DB $11, DIRF_SOUTH, 0, 0, 0, 0
    DB W_TTR, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP
    DB $04, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP, O_EMP, O_BNS, O_EMP, O_EMP
    DB $09, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP
    D_BPTR DataX_TitleMusic_song, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, R_RNE, R_RSW, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB O_GRS, O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, R_RSE, R_RNW, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB O_GRS, O_GRS, O_EMP, O_EMP, O_BNS, O_EMP, R_RNS, O_EMP, O_EMP, O_GRS
    DB TILESET_SEASIDE, COLORSET_AUTUMN, 0, 0, 0, 0
    DB R_SNN, R_SNN, R_SNE, G_CHS, R_RNS, G_APL, R_RNS, G_PNT, R_SNW, R_SNN
    DS 6
    DB R_OOP, R_OOP, R_ONE, R_SNN, R_ONN, R_SNN, R_ONN, R_SNN, R_ONW, R_OOP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Seaside2_puzz:
    .begin
    DB W_TST, W_TTR, O_EMP, O_EMP, O_EMP, W_TTR, O_EMP, O_EMP, W_TST, W_TST
    DB $07, DIRF_WEST, 0, 0, 0, 0
    DB W_TTR, O_EMP, O_EMP, O_EMP, O_EMP, S_BSH, G_PNT, W_RCK, W_TST, W_TST
    DB $50, DIRF_EAST, 0, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, G_CHS, O_EMP, O_EMP, W_RCK, G_APL, W_TTR, W_TST
    DB $20, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_ARW, W_TTR
    D_BPTR DataX_TitleMusic_song, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, R_RSE, R_REW, R_REW, R_REW
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, S_BSH, W_TTP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB R_RSE, R_REW, R_REW, O_BEW, R_REW, R_REW, R_RNW, W_RCK, O_EMP, W_TTR
    DB TILESET_SEASIDE, COLORSET_WINTER, 0, 0, 0, 0
    DB R_RNW, W_TTP, O_EMP, S_BSH, O_EMP, O_EMP, W_FW1, W_FNS, M_FNS, W_FNS
    DS 6
    DB W_TTP, W_TST, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_RCK
ASSERT @ - .begin == sizeof_PUZZ

DataX_Sewer1_puzz:
    .begin
    DB O_EMP, O_EMP, W_BW3, W_BE3, W_BS3, W_BS3, W_BEW, W_BS3, W_BS3, W_BW3
    DB $11, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, O_EMP, W_BEW, W_BSE, G_CHS, O_EMP, W_BEW, O_EMP, O_EMP, W_BSW
    DB $20, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, S_PPW, W_BEW, O_EMP, W_RCK, O_EMP, W_BEW, O_EMP, W_RCK, O_EMP
    DB $17, DIRF_SOUTH, 0, 0, 0, 0
    DB R_EDG, O_EMP, W_BEW, W_RCK, O_EMP, O_EMP, W_BS1, S_PPE, O_EMP, O_EMP
    D_BPTR DataX_RestYe_song, 0, 0, 0
    DB R_OOP, O_EMP, W_BS1, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB R_OOP, O_EMP, O_EMP, O_EMP, W_RCK, O_EMP, G_APL, O_EMP, W_BN1, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB R_OOP, R_EDG, R_GRT, O_EMP, G_PNT, O_EMP, O_EMP, O_EMP, W_BS1, O_EMP
    DB TILESET_SEWER, COLORSET_SEWER, 0, 0, 0, 0
    DB R_OOP, R_OOP, R_OOP, O_EMP, O_EMP, O_EMP, R_GRT, O_EMP, O_EMP, O_EMP
    DS 6
    DB R_OOP, R_OOP, R_OOP, R_EDG, R_EDG, R_EDG, R_OOP, R_EDG, R_EDG, R_EDG
ASSERT @ - .begin == sizeof_PUZZ

DataX_Sewer2_puzz:
    .begin
    DB W_BC4, W_BE3, O_EMP, W_BEW, O_EMP, O_EMP, W_BSW, W_BSE, O_EMP, O_EMP
    DB $20, DIRF_EAST, 0, 0, 0, 0
    DB W_BS3, W_BSE, O_EMP, W_BEW, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    DB $02, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, O_EMP, S_PPW, W_BEW, O_EMP, O_EMP, W_BNW, W_BNE, O_EMP, O_EMP
    DB $24, DIRF_SOUTH, 0, 0, 0, 0
    DB W_BS3, W_BSE, O_EMP, W_BS1, W_RCK, W_RCK, W_BSW, W_BEW, O_EMP, O_EMP
    D_BPTR DataX_RestYe_song, 0, 0, 0
    DB O_EMP, O_EMP, S_ARE, O_EMP, O_EMP, O_EMP, O_EMP, W_BEW, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, W_BS1, S_PPE, O_EMP, O_EMP, W_BEW, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB G_APL, O_EMP, O_EMP, S_ARS, O_EMP, O_EMP, G_PNT, W_BEW, O_EMP, G_CHS
    DB TILESET_SEWER, COLORSET_SEWER, 0, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_PPW, W_BS1, O_EMP, O_EMP
    DS 6
    DB R_EDG, O_EMP, S_ARN, O_EMP, S_ARN, O_EMP, O_EMP, R_EDG, R_EDG, R_EDG
ASSERT @ - .begin == sizeof_PUZZ

DataX_City1_puzz:
    .begin
    DB W_BE3, W_BS3, W_BS3, W_BEW, W_BS3, W_BS3, W_BS3, W_BS3, W_BS3, W_BW3
    DB $18, DIRF_SOUTH, 0, 0, 0, 0
    DB W_BE3, O_EMP, O_EMP, W_BS1, S_MTP, O_EMP, O_EMP, O_EMP, O_EMP, W_BW3
    DB $11, DIRF_SOUTH, 0, 0, 0, 0
    DB W_BE3, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_MTP, W_BW3
    DB $71, DIRF_EAST, 0, 0, 0, 0
    DB W_BE3, O_EMP, G_APL, W_BN1, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_BW3
    D_BPTR DataX_RestYe_song, 0, 0, 0
    DB W_BE3, O_EMP, O_EMP, W_BS1, G_PNT, O_EMP, O_EMP, O_EMP, S_MTP, W_BW3
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB W_BE3, O_EMP, O_EMP, S_MTP, O_EMP, W_BNW, W_BNE, O_EMP, O_EMP, W_BW3
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB W_BE3, W_BSE, O_EMP, O_EMP, O_EMP, W_BSW, W_BSE, S_MTP, O_EMP, W_BW3
    DB TILESET_CITY, COLORSET_SUMMER, 0, 0, 0, 0
    DB W_BE3, O_EMP, O_EMP, O_EMP, S_MTP, O_EMP, O_EMP, O_EMP, G_CHS, W_BW3
    DS 6
    DB W_BC4, W_BN3, W_BN3, W_BN3, W_BN3, W_BN3, W_BN3, W_BN3, W_BN3, W_BC4
ASSERT @ - .begin == sizeof_PUZZ

DataX_City2_puzz:
    .begin
    DB W_BC4, W_BE3, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_BW3, W_BC4
    DB $65, DIRF_SOUTH, 0, 0, 0, 0
    DB W_BS3, W_BS3, M_BNS, W_BS3, W_BN1, W_BS3, W_BS3, M_BNS, W_BS3, W_BS3
    DB $25, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, O_EMP, W_BS1, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    DB $50, DIRF_SOUTH, 0, 0, 0, 0
    DB G_CHS, O_EMP, O_EMP, S_MTP, O_EMP, O_EMP, O_EMP, O_EMP, W_BN1, O_EMP
    D_BPTR DataX_RestYe_song, 0, 0, 0
    DB O_EMP, O_EMP, G_APL, O_EMP, W_BS1, O_EMP, G_PNT, O_EMP, W_BS1, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB O_EMP, W_BN1, O_EMP, O_EMP, O_EMP, S_MTP, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB W_BN3, W_BE3, O_EMP, O_EMP, W_BN1, O_EMP, O_EMP, O_EMP, W_BNW, W_BN3
    DB TILESET_CITY, COLORSET_SUMMER, 0, 0, 0, 0
    DB W_BS3, W_BS3, M_BNS, W_BS3, W_BS3, W_BS3, W_BS3, M_BNS, W_BS3, W_BS3
    DS 6
    DB O_EMP, O_EMP, S_MTP, O_EMP, O_EMP, O_EMP, O_EMP, S_MTP, O_EMP, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Space1_puzz:
    .begin
    DB R_OOP, R_OOP, R_OOP, R_OOP, R_OOP, R_OOP, R_OOP, R_OOP, R_OOP, R_OOP
    DB $51, DIRF_SOUTH, 0, 0, 0, 0
    DB W_BNE, O_EMP, O_EMP, G_CHS, O_EMP, O_EMP, W_BN1, O_EMP, O_EMP, W_BN1
    DB $17, DIRF_SOUTH, 0, 0, 0, 0
    DB W_BE3, S_TGE, O_EMP, O_EMP, S_TMF, O_EMP, W_BEW, O_EMP, G_APL, W_BEW
    DB $15, DIRF_WEST, 0, 0, $47, $33
    DB W_BE3, O_EMP, W_BN1, S_TMF, O_EMP, O_EMP, W_BEW, O_EMP, O_EMP, W_BEW
    D_BPTR DataX_LightsOn_song, 0, 0, $24
    DB W_BC4, W_BS3, W_BS3, W_BS3, M_BNS, W_BNW, W_BE3, S_TGE, O_EMP, W_BEW
    D_BPTR DataX_Null_dlog, 0, $21, 0
    DB W_BE3, O_EMP, O_EMP, O_EMP, O_EMP, W_BSW, W_BEW, O_EMP, O_EMP, W_BEW
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB W_BSE, G_PNT, O_EMP, S_TEF, O_EMP, O_EMP, W_BEW, O_EMP, O_EMP, W_BS1
    DB TILESET_SPACE, COLORSET_SPACE, 0, 0, 0, $78
    DB R_GDR, O_EMP, O_EMP, O_EMP, O_EMP, W_BW1, W_BSE, O_EMP, S_TEF, R_GDR
    DB 0, 0, 0, 0, 0, $63
    DB R_OOP, R_GDR, R_GDR, R_GDR, R_GDR, R_GDR, R_GDR, R_GDR, R_GDR, R_OOP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Space2_puzz:
    .begin
    DB O_EMP, S_TME, O_EMP, S_MTP, O_EMP, S_TEF, O_EMP, O_EMP, O_EMP, S_MTP
    DB $00, DIRF_SOUTH, 0, 0, $36, $75
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_BN1, S_MTP, W_BW1, W_BN1, O_EMP
    DB $80, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, W_BW1, W_BN1, O_EMP, G_CHS, W_BEW, O_EMP, O_EMP, W_BEW, G_PNT
    DB $07, DIRF_WEST, 0, 0, 0, 0
    DB O_EMP, O_EMP, W_BEW, O_EMP, O_EMP, W_BS1, S_TME, O_EMP, W_BEW, O_EMP
    D_BPTR DataX_LightsOn_song, 0, $01, 0
    DB S_ARS, O_EMP, W_BEW, S_ARE, O_EMP, O_EMP, W_BW1, W_BS3, W_BSE, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB O_EMP, O_EMP, W_BEW, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB R_GDR, O_EMP, W_BEW, O_EMP, R_GDR, R_GDR, R_GDR, R_GDR, R_GDR, R_GDR
    DB TILESET_SPACE, COLORSET_SPACE, 0, 0, 0, 0
    DB O_EMP, O_EMP, W_BS1, O_EMP, O_EMP, S_TEF, O_EMP, O_EMP, O_EMP, S_ARW
    DB 0, 0, 0, 0, 0, $05
    DB O_EMP, O_EMP, O_EMP, O_EMP, G_APL, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Space3_puzz:
    .begin
    DB O_EMP, W_BSW, W_BS3, W_BSE, O_EMP, O_EMP, W_BEW, R_OOP, R_OOP, R_OOP
    DB $40, DIRF_EAST, 0, 0, 0, 0
    DB S_TGE, O_EMP, S_BSH, O_EMP, O_EMP, O_EMP, W_BEW, O_EMP, O_EMP, O_EMP
    DB $17, DIRF_EAST, 0, 0, $79, 0
    DB G_APL, O_EMP, W_BN1, O_EMP, O_EMP, O_EMP, W_BEW, S_PPE, S_TEF, O_EMP
    DB $89, DIRF_WEST, 0, 0, 0, $75
    DB O_EMP, O_EMP, W_BEW, S_PPE, O_EMP, G_CHS, W_BEW, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_LightsOn_song, 0, 0, 0
    DB O_EMP, O_EMP, W_BEW, O_EMP, O_EMP, O_EMP, W_BEW, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB R_GDR, R_GDR, W_BEW, O_EMP, O_EMP, O_EMP, W_BS1, R_GDR, R_GDR, R_GDR
    D_BPTR DataX_Null_dlog, 0, 0, 0
    DB S_ARE, G_PNT, W_BS1, O_EMP, S_ARN, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    DB TILESET_SPACE, COLORSET_SPACE, 0, 0, 0, 0
    DB O_EMP, S_MTP, O_EMP, O_EMP, S_ARS, S_TEF, O_EMP, S_ARW, O_EMP, S_TGE
    DB 0, 0, 0, 0, $10, $28
    DB R_GDR, R_GDR, R_GDR, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

;;;=========================================================================;;;
