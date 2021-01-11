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

INCLUDE "src/puzzle.inc"

;;;=========================================================================;;;

D_MUSIC: MACRO
    DB BANK(\1), LOW(\1), HIGH(\1), (\2), (\3), (\4)
ENDM

;;;=========================================================================;;;

SECTION "PuzzleData", ROM0

Data_Puzzle0_puzz:
    .begin
    DB W_TST, W_TTR, W_TTR, O_GRS, W_TTR, W_TTR, O_EMP, W_TTR, W_TST, W_TST
    DB $17, DIRF_WEST, 0, 0, 0, 0
    DB W_TST, G_PNT, O_EMP, O_EMP, O_GRS, O_EMP, O_EMP, O_EMP, W_TST, W_TST
    DB $71, DIRF_SOUTH, 0, 0, 0, 0
    DB W_TST, W_TTP, W_FLT, W_FMD, W_FRT, O_EMP, W_FLT, W_FRT, W_TTR, W_TST
    DB $58, DIRF_SOUTH, 0, 0, 0, 0
    DB W_TST, W_TTR, W_RCK, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, G_CHS, W_TST
    D_MUSIC Data_TitleMusic_song, 0, 0, 0
    DB W_TST, W_FLT, W_FRT, O_EMP, W_FLT, W_FMD, W_FMD, W_FMD, W_FRT, W_TST
    DS 6
    DB W_TST, O_GRS, O_GRS, O_EMP, O_EMP, O_EMP, G_APL, W_TTP, O_EMP, W_TST
    DS 6
    DB W_TST, O_GRS, O_EMP, O_EMP, O_GRS, O_EMP, W_RCK, W_TTR, O_GRS, W_TST
    DS 6
    DB W_TST, O_EMP, W_TTP, O_GRS, O_EMP, O_EMP, O_EMP, O_GRS, O_GRS, W_TST
    DS 6
    DB W_TST, W_TTP, W_TST, W_TTP, W_TTP, O_EMP, O_EMP, W_TTP, W_TTP, W_TST
ASSERT @ - .begin == sizeof_PUZZ

Data_Puzzle1_puzz:
    .begin
    DB W_TST, W_TST, W_TST, W_TST, O_GRS, W_TTR, W_TST, W_TTR, W_TST, W_TST
    DB $63, DIRF_EAST, 0, 0, 0, 0
    DB W_TST, W_TST, W_TTR, W_TTR, O_EMP, O_EMP, W_TTR, O_EMP, W_TST, W_TST
    DB $62, DIRF_EAST, 0, 0, 0, 0
    DB W_TST, W_TST, W_FLT, W_FMD, W_FMD, W_FMD, W_FMD, W_FRT, W_TTR, W_TST
    DB $61, DIRF_EAST, 0, 0, 0, 0
    DB W_TST, W_TTR, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, W_RCK, O_EMP, W_TTR
    D_MUSIC Data_RestYe_song, 0, 0, 0
    DB W_TST, W_TTP, W_TST, O_EMP, O_GRS, O_GRS, O_EMP, O_EMP, W_TTP, W_TTP
    DS 6
    DB W_TST, W_TTR, W_TTR, W_RCK, O_EMP, O_GRS, O_EMP, W_RCK, W_TTR, W_TST
    DS 6
    DB W_TST, O_GRS, O_EMP, O_EMP, O_GRS, O_EMP, G_PNT, G_APL, G_CHS, W_TST
    DS 6
    DB W_TTR, O_EMP, W_TTP, W_TTP, O_EMP, O_EMP, W_TTP, W_TTP, W_TTP, W_TST
    DS 6
    DB W_TTP, O_EMP, W_TTR, W_TST, W_TTP, W_TTP, W_TST, W_TST, W_TST, W_TST
ASSERT @ - .begin == sizeof_PUZZ

Data_Puzzle2_puzz:
    .begin
    DB W_TST, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TST
    DB $11, DIRF_EAST, 0, 0, 0, 0
    DB W_TTR, O_GRS, O_EMP, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, W_TST
    DB $20, DIRF_EAST, 0, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, O_EMP, O_GRS, O_EMP, O_EMP, W_TST
    DB $31, DIRF_EAST, 0, 0, 0, 0
    DB W_TTP, O_GRS, O_GRS, O_EMP, O_EMP, W_TTP, O_EMP, O_EMP, W_RCK, W_TST
    D_MUSIC Data_TitleMusic_song, 0, 0, 0
    DB W_TTR, W_TTP, W_FLT, W_FMD, W_FRT, W_TTR, W_RCK, O_EMP, O_GRS, W_TST
    DS 6
    DB W_TTP, W_TTR, O_EMP, O_EMP, G_PNT, O_EMP, O_EMP, O_GRS, O_GRS, W_TST
    DS 6
    DB W_TST, O_GRS, G_APL, O_EMP, O_EMP, W_FLT, W_FMD, W_FMD, W_FRT, W_TST
    DS 6
    DB W_TST, O_GRS, O_GRS, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, G_CHS, W_TST
    DS 6
    DB W_TST, W_TTP, O_GRS, W_TST, W_TTP, W_TTP, W_TTP, W_TTP, W_TTP, W_TST
ASSERT @ - .begin == sizeof_PUZZ

Data_Puzzle3_puzz:
    .begin
    DB O_EMP, O_EMP, O_EMP, O_EMP, W_RSO, S_ARS, O_EMP, O_EMP, S_ARW, W_RSO
    DB $89, DIRF_SOUTH, 0, 0, 0, 0
    DB W_BLD, O_EMP, O_EMP, O_EMP, S_ARW, O_EMP, O_EMP, O_EMP, O_EMP, G_CHS
    DB $12, DIRF_EAST, 0, 0, 0, 0
    DB W_CSO, W_CSO, W_CSO, O_RMD, W_CSO, M_RNA, W_CSO, O_RWL, O_RWR, W_CSO
    DB $07, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, O_EMP, G_APL, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_TTP
    D_MUSIC Data_TitleMusic_song, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, W_BLD, O_EMP, O_EMP, W_TTP, W_FLT, W_FRT, W_TTR
    DS 6
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_BLD, W_TTR, O_EMP, O_EMP, S_ARS
    DS 6
    DB O_EMP, W_BLD, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    DS 6
    DB O_EMP, G_PNT, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    DS 6
    DB O_EMP, O_EMP, O_EMP, O_EMP, S_ARN, O_EMP, S_ARE, O_EMP, O_EMP, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

Data_Puzzle4_puzz:
    .begin
    DB W_TST, W_TTR, O_EMP, O_EMP, O_EMP, W_TTR, O_EMP, O_EMP, W_TST, W_TST
    DB $07, DIRF_WEST, 0, 0, 0, 0
    DB W_TTR, O_EMP, O_EMP, O_EMP, O_EMP, S_BSH, G_PNT, W_BLD, W_TST, W_TST
    DB $50, DIRF_EAST, 0, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, G_CHS, O_EMP, O_EMP, W_BLD, G_APL, W_TTR, W_TST
    DB $20, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_ARW, W_TTR
    D_MUSIC Data_TitleMusic_song, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, R_RSE, R_REW, R_REW, R_REW
    DS 6
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP, W_TTP
    DS 6
    DB R_RSE, R_REW, R_REW, O_BEW, R_REW, R_REW, R_RNW, O_EMP, S_BSH, W_TTR
    DS 6
    DB R_RNW, W_TTP, O_EMP, S_BSH, O_EMP, O_EMP, W_FLT, W_FRT, O_EMP, O_EMP
    DS 6
    DB W_TTP, W_TST, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, M_RNS, O_EMP, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

Data_Puzzle5_puzz:
    .begin
    DB O_EMP, O_EMP, W_BW3, W_BE3, W_BS3, W_BS3, W_BEW, W_BS3, W_BS3, W_BW3
    DB $11, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, O_EMP, W_BEW, W_BSE, G_CHS, O_EMP, W_BEW, O_EMP, O_EMP, W_BSW
    DB $20, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, S_PPW, W_BEW, O_EMP, W_BLD, O_EMP, W_BEW, O_EMP, W_BLD, O_EMP
    DB $17, DIRF_SOUTH, 0, 0, 0, 0
    DB W_BNE, O_EMP, W_BEW, W_BLD, O_EMP, O_EMP, W_BS1, S_PPE, O_EMP, O_EMP
    D_MUSIC Data_TitleMusic_song, 0, 0, 0
    DB W_BE3, O_EMP, W_BS1, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    DS 6
    DB W_BE3, O_EMP, O_EMP, O_EMP, W_BLD, O_EMP, G_APL, O_EMP, W_BN1, O_EMP
    DS 6
    DB W_BC4, W_BN3, W_BNE, O_EMP, G_PNT, O_EMP, O_EMP, O_EMP, W_BS1, O_EMP
    DS 6
    DB W_BS3, W_BS3, W_BEW, O_EMP, O_EMP, O_EMP, W_BN1, O_EMP, O_EMP, O_EMP
    DS 6
    DB O_EMP, O_EMP, W_BW3, W_BN3, W_BN3, W_BN3, W_BC4, W_BN3, W_BN3, W_BN3
ASSERT @ - .begin == sizeof_PUZZ

Data_Puzzle6_puzz:
    .begin
    DB W_BC4, W_BE3, O_EMP, W_BEW, O_EMP, O_EMP, W_BSW, W_BSE, O_EMP, O_EMP
    DB $20, DIRF_EAST, 0, 0, 0, 0
    DB W_BS3, W_BSE, O_EMP, W_BEW, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    DB $02, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, O_EMP, S_PPW, W_BEW, O_EMP, O_EMP, W_BNW, W_BNE, O_EMP, O_EMP
    DB $24, DIRF_SOUTH, 0, 0, 0, 0
    DB W_BLD, W_BLD, O_EMP, W_BS1, W_BLD, W_BLD, W_BSW, W_BEW, O_EMP, O_EMP
    D_MUSIC Data_TitleMusic_song, 0, 0, 0
    DB O_EMP, O_EMP, S_ARE, O_EMP, O_EMP, O_EMP, O_EMP, W_BEW, O_EMP, O_EMP
    DS 6
    DB O_EMP, O_EMP, O_EMP, W_BS1, S_PPE, O_EMP, O_EMP, W_BEW, O_EMP, O_EMP
    DS 6
    DB G_APL, O_EMP, O_EMP, S_ARS, O_EMP, O_EMP, G_PNT, W_BEW, O_EMP, G_CHS
    DS 6
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_PPW, W_BEW, O_EMP, O_EMP
    DS 6
    DB W_BNE, O_EMP, S_ARN, O_EMP, S_ARN, O_EMP, O_EMP, W_BEW, O_EMP, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

Data_Puzzle7_puzz:
    .begin
    DB W_BE3, W_BS3, W_BS3, W_BEW, W_BS3, W_BS3, W_BS3, W_BS3, W_BS3, W_BW3
    DB $18, DIRF_SOUTH, 0, 0, 0, 0
    DB W_BE3, O_EMP, O_EMP, W_BS1, S_MTP, O_EMP, O_EMP, O_EMP, O_EMP, W_BW3
    DB $11, DIRF_SOUTH, 0, 0, 0, 0
    DB W_BE3, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_MTP, W_BW3
    DB $71, DIRF_EAST, 0, 0, 0, 0
    DB W_BE3, O_EMP, G_APL, W_BN1, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_BW3
    D_MUSIC Data_TitleMusic_song, 0, 0, 0
    DB W_BE3, O_EMP, O_EMP, W_BS1, G_PNT, O_EMP, O_EMP, O_EMP, S_MTP, W_BW3
    DS 6
    DB W_BE3, O_EMP, O_EMP, S_MTP, O_EMP, W_BNW, W_BNE, O_EMP, O_EMP, W_BW3
    DS 6
    DB W_BE3, W_BSE, O_EMP, O_EMP, O_EMP, W_BSW, W_BSE, S_MTP, O_EMP, W_BW3
    DS 6
    DB W_BE3, O_EMP, O_EMP, O_EMP, S_MTP, O_EMP, O_EMP, O_EMP, G_CHS, W_BW3
    DS 6
    DB W_BC4, W_BN3, W_BN3, W_BN3, W_BN3, W_BN3, W_BN3, W_BN3, W_BN3, W_BC4
ASSERT @ - .begin == sizeof_PUZZ

Data_Puzzle8_puzz:
    .begin
    DB W_BLD, O_EMP, O_EMP, O_EMP, S_PPW, W_RSO, O_EMP, O_EMP, S_MTP, O_EMP
    DB $01, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, S_BSH, O_EMP, O_EMP, S_TEF, S_TGE, O_EMP, O_EMP, W_BLD, W_BLD
    DB $10, DIRF_SOUTH, 0, 0, $46, $27
    DB W_BLD, O_EMP, O_EMP, O_EMP, O_EMP, W_BLD, O_EMP, S_TEF, W_BLD, W_BLD
    DB $21, DIRF_SOUTH, 0, 0, 0, $14
    DB W_CSO, W_CRV, O_RMD, W_CSO, M_RNA, W_CSO, O_RWL, O_RWR, W_CSO, W_CRV
    D_MUSIC Data_TitleMusic_song, 0, 0, 0
    DB O_EMP, M_RNS, O_EMP, O_EMP, G_PNT, O_EMP, S_TGE, O_EMP, S_TMF, W_RSO
    DB 0, 0, 0, 0, $15, $77
    DB S_ARE, W_RSO, G_APL, O_EMP, O_EMP, W_BLD, W_BLD, W_BLD, R_RSE, R_REW
    DS 6
    DB R_REW, R_RSW, O_EMP, W_BLD, O_EMP, O_EMP, S_ARS, G_CHS, R_RNS, O_EMP
    DS 6
    DB O_EMP, R_RNE, R_REW, R_REW, R_REW, R_REW, R_RSW, S_TMF, R_RNS, O_EMP
    DB 0, 0, 0, 0, 0, $48
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, R_RNE, R_REW, R_RNW, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

;;;=========================================================================;;;

SECTION "PuzzlePtrs", ROM0

Data_Puzzles_puzz_ptr_arr::
    DW Data_Puzzle0_puzz
    DW Data_Puzzle1_puzz
    DW Data_Puzzle2_puzz
    DW Data_Puzzle3_puzz
    DW Data_Puzzle4_puzz
    DW Data_Puzzle5_puzz
    DW Data_Puzzle6_puzz
    DW Data_Puzzle7_puzz
    DW Data_Puzzle8_puzz
ASSERT @ - Data_Puzzles_puzz_ptr_arr == 2 * NUM_PUZZLES

;;;=========================================================================;;;
