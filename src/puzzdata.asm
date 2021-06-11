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

D_ANIM: MACRO
    STATIC_ASSERT _NARG == 2 || _NARG == 6
    DB (\1), (\2)
    IF _NARG > 2
    DB (\3), (\4), (\5), (\6)
    ELSE
    DS 4
    ENDC
ENDM

D_BPTR: MACRO
    STATIC_ASSERT _NARG == 1 || _NARG == 4
    DB BANK(\1), LOW(\1), HIGH(\1)
    IF _NARG > 1
    DB (\2), (\3), (\4)
    ELSE
    DS 3
    ENDC
ENDM

D_PAR: MACRO
    STATIC_ASSERT _NARG == 1 || _NARG == 5
    DB LOW(\1), HIGH(\1)
    IF _NARG > 1
    DB (\2), (\3), (\4), (\5)
    ELSE
    DS 4
    ENDC
ENDM

D_SETS: MACRO
    STATIC_ASSERT _NARG == 2 || _NARG == 6
    DB (\1), (\2)
    IF _NARG > 2
    DB (\3), (\4), (\5), (\6)
    ELSE
    DS 4
    ENDC
ENDM

;;;=========================================================================;;;

SECTION "PuzzlePtrs", ROMX

;;; An array that maps from puzzle numbers to pointers to PUZZ structs stored
;;; in BANK("PuzzleData").
DataX_Puzzles_puzz_ptr_arr::
    DW DataX_Forest0_puzz
    DW DataX_Forest1_puzz
    DW DataX_Forest2_puzz
    DW DataX_Forest3_puzz
    DW DataX_Forest4_puzz
    DW DataX_ForestBonus_puzz
    DW DataX_Forest6_puzz
    DW DataX_Farm0_puzz
    DW DataX_Farm1_puzz
    DW DataX_Farm2_puzz
    DW DataX_FarmBonus_puzz
    DW DataX_Farm4_puzz
    DW DataX_Mountain0_puzz
    DW DataX_Mountain1_puzz
    DW DataX_Mountain2_puzz
    DW DataX_Mountain3_puzz
    DW DataX_MountainBonus_puzz
    DW DataX_Mountain3_puzz  ; TODO
    DW DataX_Lake0_puzz
    DW DataX_Lake1_puzz
    DW DataX_LakeBonus_puzz
    DW DataX_Lake3_puzz
    DW DataX_Lake4_puzz
    DW DataX_Sewer0_puzz
    DW DataX_Sewer1_puzz
    DW DataX_Sewer2_puzz
    DW DataX_Sewer3_puzz
    DW DataX_SewerBonus_puzz
    DW DataX_Sewer5_puzz
    DW DataX_City0_puzz
    DW DataX_City1_puzz
    DW DataX_City2_puzz
    DW DataX_CityBonus_puzz
    DW DataX_City4_puzz
    DW DataX_Space0_puzz
    DW DataX_Space1_puzz
    DW DataX_Space2_puzz
    DW DataX_Space3_puzz
    DW DataX_Space4_puzz
    DW DataX_Space5_puzz
ASSERT @ - DataX_Puzzles_puzz_ptr_arr == 2 * NUM_PUZZLES

;;;=========================================================================;;;

SECTION "PuzzleData", ROMX

DataX_Forest0_puzz:
    .begin
    DB W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST
    D_ANIM $41, DIRF_EAST
    DB W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST
    D_ANIM $1b, G_APL
    DB W_TST, W_TST, W_TST, W_TST, W_TST, W_TTR, W_TTR, W_TTR, W_TTR, W_TST
    D_ANIM $2b, G_CHS
    DB W_TST, W_TTR, W_TTR, W_TTR, W_TTR, O_EMP, O_EMP, O_EMP, G_PNT, W_TST
    D_BPTR DataX_Cutest_song
    DB W_TST, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_TTP, W_TTP, W_TTP, W_TST
    D_BPTR DataX_Forest0Intro_dlog
    DB W_TST, W_TTP, W_TTP, O_EMP, W_TTP, W_TTP, W_TST, W_TST, W_TST, W_TST
    D_BPTR DataX_Forest0Outro_dlog
    DB W_TST, W_TST, W_TST, W_TTP, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST
    D_SETS TILESET_PUZZ_FARM, COLORSET_SPRING
    DB W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST
    D_PAR $0003
    DB W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST
ASSERT @ - .begin == sizeof_PUZZ

DataX_Forest1_puzz:
    .begin
    DB W_TST, W_TST, W_TST, W_TTR, W_TTR, W_TST, W_TST, W_TST, W_TST, W_TST
    D_ANIM $51, DIRF_EAST
    DB W_TST, W_TTR, W_TTR, O_EMP, O_GRS, W_TTR, W_TTR, W_TTR, W_TTR, W_TST
    D_ANIM $65, DIRF_WEST
    DB W_TST, O_GRS, O_EMP, O_EMP, O_EMP, O_GRS, O_EMP, O_EMP, G_PNT, W_TST
    D_ANIM $2b, G_CHS
    DB W_TST, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, G_APL, W_TST
    D_BPTR DataX_Cutest_song
    DB W_TST, O_EMP, O_EMP, O_EMP, W_FW1, W_FNS, W_FNS, W_FE1, W_TTP, W_TST
    D_BPTR DataX_Forest1Intro_dlog
    DB W_TST, O_EMP, O_EMP, O_EMP, O_GRS, O_GRS, O_GRS, W_TTP, W_TST, W_TST
    D_BPTR DataX_Forest1Outro_dlog
    DB W_TST, W_TTP, W_TTP, O_GRS, O_EMP, O_EMP, O_GRS, W_TST, W_TST, W_TST
    D_SETS TILESET_PUZZ_FARM, COLORSET_SPRING
    DB W_TST, W_TST, W_TST, W_TTP, W_TTP, W_TTP, W_TTP, W_TST, W_TST, W_TST
    D_PAR $0006
    DB W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST, W_TST
ASSERT @ - .begin == sizeof_PUZZ

DataX_Forest2_puzz:
    .begin
    DB W_TTP, W_TTR, W_TTR, W_TTR, W_TST, W_TST, W_TTR, W_TTR, W_TTR, W_TST
    D_ANIM $58, DIRF_SOUTH
    DB W_TST, O_EMP, O_EMP, O_EMP, W_TTR, W_TTR, O_EMP, O_EMP, O_EMP, W_TST
    D_ANIM $38, DIRF_WEST
    DB W_TST, G_APL, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, G_PNT, O_EMP, W_TST
    D_ANIM $11, DIRF_EAST
    DB W_TST, W_TTP, O_EMP, O_EMP, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, W_TTR
    D_BPTR DataX_RestYe_song
    DB W_TST, W_TTR, O_EMP, O_GRS, W_TST, W_TTP, O_EMP, W_FW1, W_FNS, W_FNS
    D_BPTR DataX_Forest2Intro_dlog
    DB W_TST, O_EMP, O_EMP, O_EMP, W_TTR, W_TTR, O_EMP, O_EMP, O_EMP, W_TTP
    D_BPTR DataX_Forest2Outro_dlog
    DB W_TTR, O_GRS, O_EMP, O_EMP, O_GRS, W_RCK, O_EMP, O_GRS, O_GRS, W_TST
    D_SETS TILESET_PUZZ_FARM, COLORSET_SUMMER
    DB W_TTP, O_EMP, G_CHS, O_EMP, O_EMP, O_EMP, O_GRS, O_GRS, W_TTP, W_TST
    D_PAR $0018
    DB W_TST, W_TTP, W_TTP, W_TTP, W_TTP, W_TTP, W_TTP, W_TTP, W_TST, W_TST
ASSERT @ - .begin == sizeof_PUZZ

DataX_Forest3_puzz:
    .begin
    DB W_TST, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TST
    D_ANIM $11, DIRF_EAST
    DB W_TTR, O_GRS, O_EMP, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, W_TST
    D_ANIM $20, DIRF_EAST
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, O_EMP, O_GRS, O_EMP, O_EMP, W_TST
    D_ANIM $31, DIRF_EAST
    DB W_TTP, O_GRS, O_GRS, O_EMP, O_EMP, W_TTP, O_EMP, O_EMP, W_RCK, W_TST
    D_BPTR DataX_RestYe_song
    DB W_TTR, W_TTP, W_FW1, W_FNS, W_FE1, W_TTR, W_RCK, O_EMP, O_GRS, W_TST
    D_BPTR DataX_Forest3Intro_dlog
    DB W_TTP, W_TTR, O_EMP, O_EMP, G_PNT, O_EMP, O_EMP, O_GRS, O_GRS, W_TST
    D_BPTR DataX_Null_dlog
    DB W_TST, O_GRS, G_APL, O_EMP, O_EMP, W_FW1, W_FNS, W_FNS, W_FE1, W_TST
    D_SETS TILESET_PUZZ_FARM, COLORSET_AUTUMN
    DB W_TST, O_GRS, O_GRS, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, G_CHS, W_TST
    D_PAR $0025
    DB W_TST, W_TTP, O_GRS, W_TST, W_TTP, W_TTP, W_TTP, W_TTP, W_TTP, W_TST
ASSERT @ - .begin == sizeof_PUZZ

DataX_Forest4_puzz:
    .begin
    DB W_TST, W_TTR, O_GRS, O_GRS, W_TTR, W_TTR, W_TST, W_TST, W_TST, W_TST
    D_ANIM $78, DIRF_SOUTH
    DB W_TTR, O_EMP, O_EMP, O_EMP, O_EMP, S_BSH, W_TST, W_TTR, W_TTR, W_TST
    D_ANIM $11, DIRF_EAST
    DB W_FNS, W_FNS, W_FNS, W_FNS, W_FE1, O_EMP, W_TTR, O_EMP, O_EMP, W_TST
    D_ANIM $57, DIRF_WEST
    DB W_TTP, O_EMP, O_EMP, S_BSH, O_EMP, O_EMP, O_EMP, G_CHS, O_EMP, W_TST
    D_BPTR DataX_RestYe_song
    DB W_TST, O_EMP, G_PNT, W_RCK, O_EMP, O_GRS, W_TTP, W_RCK, S_BSH, W_TST
    D_BPTR DataX_Forest4Intro_dlog
    DB W_TST, O_EMP, O_EMP, O_EMP, W_FW1, W_FE1, W_TST, O_EMP, O_EMP, W_TTR
    D_BPTR DataX_Null_dlog
    DB W_TST, O_EMP, G_APL, O_EMP, O_EMP, S_BSH, W_TTR, W_FW1, W_FNS, W_FNS
    D_SETS TILESET_PUZZ_FARM, COLORSET_SUMMER
    DB W_TST, O_GRS, O_EMP, O_EMP, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, W_TTP
    D_PAR $0034
    DB W_TTR, W_TTP, W_TTP, W_TTP, W_TST, W_TTP, W_TTP, W_TTP, W_TTP, W_TST
ASSERT @ - .begin == sizeof_PUZZ

DataX_ForestBonus_puzz:
    .begin
    DB O_EMP, O_EMP, W_TTR, W_TTR, W_TTR, O_EMP, O_GRS, W_TTR, W_TST, W_TTR
    D_ANIM $13, DIRF_SOUTH
    DB O_EMP, S_BSH, O_EMP, O_EMP, S_BSH, O_EMP, O_EMP, O_GRS, W_TTR, O_GRS
    D_ANIM $00, DIRF_EAST
    DB O_GRS, W_RCK, O_EMP, W_RCK, W_TTP, W_TTP, O_EMP, O_EMP, S_BSH, O_EMP
    D_ANIM $12, DIRF_SOUTH
    DB W_FNS, W_FNS, W_FNS, W_FE1, W_TTR, W_TTR, O_EMP, O_EMP, W_TTP, O_EMP
    D_BPTR DataX_TitleMusic_song
    DB O_EMP, O_EMP, G_APL, O_EMP, O_EMP, O_EMP, O_EMP, W_TTP, W_TTR, O_EMP
    D_BPTR DataX_Null_dlog
    DB W_TTP, W_FNS, W_FE1, S_BSH, W_FW1, W_FNS, W_FE1, W_TTR, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB W_TTR, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_BSH, O_EMP, O_EMP
    D_SETS TILESET_PUZZ_FARM, COLORSET_WINTER
    DB O_GRS, O_EMP, O_EMP, G_CHS, W_RCK, O_EMP, O_EMP, W_TTP, G_PNT, O_EMP
    D_PAR $0048
    DB W_TTP, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, W_TTP, W_TST, W_TTP, W_TTP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Forest6_puzz:
    .begin
    DB W_TTP, O_GRS, O_EMP, W_TTR, O_EMP, W_TTR, W_TTR, W_TTP, O_EMP, O_GRS
    D_ANIM $32, DIRF_SOUTH
    DB W_TST, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, W_TST, G_PNT, O_EMP
    D_ANIM $57, DIRF_EAST
    DB W_TST, O_EMP, O_EMP, S_BSH, O_EMP, O_EMP, O_GRS, W_TTR, O_EMP, O_EMP
    D_ANIM $31, DIRF_SOUTH
    DB W_TST, O_EMP, O_EMP, W_TTP, O_EMP, O_EMP, O_EMP, S_BSH, O_EMP, O_EMP
    D_BPTR DataX_TitleMusic_song
    DB W_TST, W_FW1, W_FE1, W_TTR, O_EMP, O_EMP, W_TTP, W_FW1, W_FE1, W_TTP
    D_BPTR DataX_Null_dlog
    DB W_TTR, W_TTP, O_EMP, O_EMP, O_EMP, O_GRS, W_TTR, O_EMP, O_EMP, W_TST
    D_BPTR DataX_Null_dlog
    DB G_APL, W_TTR, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_TST
    D_SETS TILESET_PUZZ_FARM, COLORSET_SUMMER
    DB O_GRS, O_GRS, O_EMP, O_EMP, G_CHS, O_EMP, O_EMP, O_EMP, O_GRS, W_TST
    D_PAR $0049
    DB W_TTP, W_TTP, W_TTP, O_EMP, O_EMP, O_EMP, W_TTP, O_GRS, O_GRS, W_TST
ASSERT @ - .begin == sizeof_PUZZ

DataX_Farm0_puzz:
    .begin
    DB W_HNW, W_HNE, O_GRS, O_GRS, O_EMP, W_TTR, W_TTR, O_EMP, O_GRS, O_GRS
    D_ANIM $20, DIRF_EAST
    DB W_HSW, W_HSE, O_EMP, G_PNT, O_EMP, O_EMP, G_CHS, O_EMP, O_EMP, O_GRS
    D_ANIM $67, DIRF_WEST
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_ANIM $80, DIRF_SOUTH
    DB W_FNW, W_FNS, W_FNS, W_FNS, W_FNS, W_FNS, M_FNS, W_FNS, W_FNE, O_EMP
    D_BPTR DataX_RestYe_song
    DB W_FSE, W_COW, O_GRS, O_GRS, O_GRS, O_GRS, O_EMP, O_GRS, W_FEW, O_EMP
    D_BPTR DataX_Farm0Intro_dlog
    DB O_GRS, O_GRS, O_EMP, O_GRS, O_GRS, G_APL, O_GRS, O_GRS, W_FEW, O_EMP
    D_BPTR DataX_Null_dlog
    DB W_FNS, W_FNS, M_FNS, W_FNE, O_GRS, W_COW, O_GRS, O_GRS, W_FEW, O_EMP
    D_SETS TILESET_PUZZ_FARM, COLORSET_SPRING
    DB O_EMP, O_EMP, O_EMP, W_FSW, W_FNS, W_FNS, W_FNS, W_FNS, W_FSE, O_GRS
    D_PAR $0035
    DB O_GRS, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, O_GRS, O_GRS
ASSERT @ - .begin == sizeof_PUZZ

DataX_Farm1_puzz:
    .begin
    DB W_TTP, O_EMP, S_BSH, O_EMP, O_EMP, O_EMP, O_EMP, G_APL, O_EMP, O_EMP
    D_ANIM $66, DIRF_SOUTH
    DB W_TST, W_TTP, O_EMP, W_TTP, O_EMP, O_GRS, O_GRS, O_EMP, O_EMP, O_EMP
    D_ANIM $19, DIRF_WEST
    DB W_TTR, W_TTR, O_EMP, W_TST, W_FW1, W_FNS, W_FNS, W_FNS, M_FNS, W_FNS
    D_ANIM $60, DIRF_EAST
    DB O_EMP, O_GRS, O_EMP, W_TTR, O_EMP, O_EMP, O_GRS, O_GRS, O_EMP, O_GRS
    D_BPTR DataX_RestYe_song
    DB O_EMP, O_EMP, O_GRS, O_GRS, O_GRS, W_COW, O_EMP, O_GRS, S_BSH, O_GRS
    D_BPTR DataX_Null_dlog
    DB W_FNS, M_FNS, W_FNS, W_FNS, W_FNS, W_FNS, W_FNS, W_FNE, O_EMP, W_COW
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, O_EMP, W_HNW, W_HNE, O_EMP, O_GRS, W_FSW, M_FNS, W_FNS
    D_SETS TILESET_PUZZ_FARM, COLORSET_SUMMER
    DB O_EMP, O_EMP, G_CHS, W_HSW, W_HSE, G_PNT, O_EMP, O_EMP, O_EMP, O_EMP
    D_PAR $0040
    DB O_GRS, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, O_GRS, W_COW
ASSERT @ - .begin == sizeof_PUZZ

DataX_Farm2_puzz:
    .begin
    DB O_EMP, O_GRS, O_EMP, O_GRS, O_GRS, O_EMP, W_FEW, O_EMP, O_EMP, G_PNT
    D_ANIM $66, DIRF_SOUTH
    DB O_GRS, O_GRS, W_FW1, W_FNS, W_FNS, M_FNS, W_FSE, S_BSH, W_RCK, W_HNW
    D_ANIM $49, DIRF_WEST
    DB O_GRS, O_EMP, O_GRS, W_COW, O_EMP, O_EMP, G_APL, O_EMP, O_EMP, W_HSW
    D_ANIM $00, DIRF_SOUTH
    DB W_FNW, M_FNS, W_FNS, W_FE1, O_EMP, O_EMP, O_EMP, W_TTP, W_FW1, W_FNS
    D_BPTR DataX_RestYe_song
    DB W_FSE, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_TTR, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_GRS, O_EMP, O_EMP, W_TTP, S_BSH, S_BSH, S_BSH, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, G_CHS, W_TST, O_EMP, O_EMP, O_EMP, W_RCK, O_EMP, O_EMP
    D_SETS TILESET_PUZZ_FARM, COLORSET_SUMMER
    DB O_GRS, O_EMP, O_EMP, W_TTR, W_FW1, W_FNS, W_FNS, W_FNS, M_FNS, W_FNS
    D_PAR $0052
    DB S_BSH, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_COW
ASSERT @ - .begin == sizeof_PUZZ

DataX_Farm4_puzz:
    .begin
    DB O_GRS, O_EMP, O_EMP, O_EMP, W_FEW, O_GRS, O_GRS, O_EMP, W_COW, O_GRS
    D_ANIM $03, DIRF_SOUTH
    DB O_EMP, O_EMP, G_APL, O_EMP, W_FSW, W_FNS, W_FNS, M_FNS, W_FNS, W_FNS
    D_ANIM $72, DIRF_WEST
    DB O_EMP, O_EMP, O_EMP, O_EMP, W_TTP, O_EMP, O_EMP, O_EMP, W_RCK, O_EMP
    D_ANIM $29, DIRF_SOUTH
    DB O_EMP, O_GRS, O_GRS, O_EMP, W_TTR, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_RestYe_song
    DB O_GRS, O_EMP, O_GRS, O_EMP, O_EMP, O_EMP, W_TTP, O_EMP, O_EMP, G_PNT
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_TTR, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, W_FW1, W_FNS, W_FNS, M_FNS, W_FNS, M_FNS, W_FNS, W_FNS
    D_SETS TILESET_PUZZ_FARM, COLORSET_SUMMER
    DB O_EMP, O_EMP, O_EMP, W_HNW, W_HNE, O_EMP, W_COW, O_EMP, O_GRS, O_GRS
    D_PAR $0033
    DB O_EMP, O_GRS, O_EMP, W_HSW, W_HSE, G_CHS, W_RCK, O_GRS, O_GRS, O_GRS
ASSERT @ - .begin == sizeof_PUZZ

DataX_FarmBonus_puzz:
    .begin
    DB O_GRS, O_GRS, O_EMP, O_EMP, W_COW, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_ANIM $80, DIRF_EAST
    DB O_GRS, W_FNW, W_FE1, O_EMP, O_EMP, O_EMP, O_EMP, W_HNW, W_HNE, O_EMP
    D_ANIM $49, DIRF_WEST
    DB O_GRS, W_FEW, O_GRS, O_EMP, O_EMP, O_EMP, G_APL, W_HSW, W_HSE, O_EMP
    D_ANIM $00, DIRF_SOUTH
    DB O_GRS, W_FW3, W_FNS, M_FNS, W_FE1, O_EMP, O_GRS, O_GRS, O_GRS, O_EMP
    D_BPTR DataX_RestYe_song
    DB O_GRS, W_FEW, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, O_EMP, O_GRS
    D_BPTR DataX_Null_dlog
    DB O_GRS, W_FEW, O_EMP, G_CHS, O_EMP, W_FNW, W_FNS, W_FNS, W_FNS, W_FNS
    D_BPTR DataX_Null_dlog
    DB O_GRS, W_FEW, O_EMP, O_EMP, O_EMP, W_FEW, O_EMP, G_PNT, O_GRS, O_GRS
    D_SETS TILESET_PUZZ_FARM, COLORSET_AUTUMN
    DB O_GRS, W_FSW, W_FE1, O_EMP, W_COW, W_FSW, M_FNS, W_FNS, W_FE1, O_EMP
    D_PAR $0059
    DB O_GRS, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, O_EMP, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Mountain0_puzz:
    .begin
    DB O_EMP, O_GRS, W_TST, O_CW3, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_ANIM $59, DIRF_SOUTH
    DB O_GRS, O_EMP, W_TTR, O_CW3, O_EMP, W_TTP, O_EMP, O_EMP, G_PNT, O_EMP
    D_ANIM $82, DIRF_EAST
    DB O_EMP, G_APL, O_EMP, W_CSW, O_CW3, W_TTR, O_EMP, O_EMP, O_EMP, S_ARW
    D_ANIM $50, DIRF_EAST
    DB O_EMP, W_RCK, O_EMP, W_RCK, O_CW3, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_ComingRound_song
    DB O_EMP, S_ARE, O_EMP, O_EMP, W_CSW, W_CS3, O_RWL, O_RWR, W_CS3, W_CS3
    D_BPTR DataX_Mountain0Intro_dlog
    DB O_EMP, O_EMP, O_GRS, O_EMP, S_ARS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB W_TTP, O_EMP, O_GRS, O_GRS, O_EMP, O_EMP, W_RCK, O_EMP, O_GRS, O_EMP
    D_SETS TILESET_PUZZ_MOUNTAIN, COLORSET_SUMMER
    DB W_TST, W_TTP, O_GRS, O_EMP, W_RCK, G_CHS, O_EMP, O_EMP, O_EMP, S_ARW
    D_PAR $0026
    DB W_TTR, W_TST, O_EMP, O_GRS, O_EMP, O_EMP, O_EMP, S_ARN, O_EMP, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Mountain1_puzz:
    ;; TODO: This puzzle is solvable, but it's too hard for this part of the
    ;; game.  Maybe make it a bonus puzzle?
    .begin
    DB O_EMP, O_EMP, W_RCK, W_TTP, O_CW3, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_ANIM $79, DIRF_SOUTH
    DB O_EMP, O_EMP, O_EMP, W_TTR, O_CW3, S_ARS, O_EMP, G_APL, O_EMP, O_EMP
    D_ANIM $74, DIRF_WEST
    DB O_EMP, G_PNT, O_EMP, W_RCK, O_CW3, O_EMP, O_EMP, O_EMP, O_EMP, W_RCK
    D_ANIM $50, DIRF_EAST
    DB O_EMP, O_EMP, O_EMP, O_EMP, W_CSW, O_RMD, W_CS3, O_RMD, W_CS3, W_CW3
    D_BPTR DataX_ComingRound_song
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_CW3
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, S_BSH, O_EMP, O_EMP, W_RCK, O_EMP, O_EMP, O_EMP, W_CW3
    D_BPTR DataX_Null_dlog
    DB W_CS3, W_CS3, O_RWL, O_RWR, W_CS3, W_CW3, W_RCK, O_EMP, S_BSH, W_CSW
    D_SETS TILESET_PUZZ_MOUNTAIN, COLORSET_SUMMER
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_CW3, W_TTP, O_EMP, O_EMP, O_EMP
    D_PAR $0067
    DB O_EMP, O_EMP, G_CHS, O_EMP, O_EMP, W_CW3, W_TTR, O_EMP, S_ARN, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Mountain2_puzz:
    .begin
    DB R_KST, R_KOP, R_KST, R_KOP, R_KOP, R_KST, R_KOP, R_KOP, R_KOP, R_KST
    D_ANIM $70, DIRF_SOUTH
    DB R_KOP, R_KST, R_KS3, R_KS3, R_KS3, R_KS3, R_KST, R_KOP, R_KS3, R_KS3
    D_ANIM $84, DIRF_EAST
    DB R_KS3, R_KSE, O_EMP, O_GRS, O_EMP, S_ARW, R_KSW, R_KSE, O_EMP, O_EMP
    D_ANIM $28, DIRF_SOUTH
    DB O_CW3, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, G_CHS
    D_BPTR DataX_ComingRound_song
    DB O_CW3, O_EMP, O_EMP, S_ARS, O_EMP, G_APL, O_EMP, O_GRS, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_CW3, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB W_CSW, O_RMD, W_CS3, O_CW3, O_GRS, O_CE3, W_CS3, O_RMD, W_CS3, M_RNA
    D_SETS TILESET_PUZZ_MOUNTAIN, COLORSET_SUMMER
    DB O_EMP, S_BSH, O_EMP, W_CSW, W_CS3, W_CSE, O_EMP, O_EMP, O_EMP, O_EMP
    D_PAR $0999  ; TODO: choose correct par value
    DB O_EMP, O_EMP, W_TTP, W_TTP, O_EMP, O_EMP, O_GRS, O_EMP, G_PNT, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Mountain3_puzz:
    .begin
    DB O_EMP, O_EMP, O_EMP, O_EMP, W_TTR, S_ARS, O_EMP, O_EMP, S_ARW, W_TTR
    D_ANIM $89, DIRF_SOUTH
    DB W_CS3, O_CW3, O_EMP, O_EMP, S_ARW, O_EMP, O_EMP, O_EMP, O_EMP, G_CHS
    D_ANIM $12, DIRF_EAST
    DB O_GRS, W_CSW, W_CS3, O_RMD, W_CS3, M_RNA, W_CS3, O_RWL, O_RWR, W_CS3
    D_ANIM $07, DIRF_SOUTH
    DB O_EMP, O_EMP, G_APL, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_CE3, W_CS3
    D_BPTR DataX_ComingRound_song
    DB O_EMP, O_EMP, O_EMP, W_RCK, O_EMP, O_EMP, O_CE3, W_CS3, W_CSE, O_GRS
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_CW1, W_CSE, O_GRS, O_EMP, S_ARS
    D_BPTR DataX_Null_dlog
    DB O_RMD, W_CE1, O_EMP, O_EMP, O_GRS, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP
    D_SETS TILESET_PUZZ_MOUNTAIN, COLORSET_SUMMER
    DB O_EMP, G_PNT, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS
    D_PAR $0999  ; TODO: choose correct par value
    DB O_GRS, O_GRS, O_EMP, O_GRS, S_ARN, O_EMP, S_ARE, O_EMP, O_GRS, O_GRS
ASSERT @ - .begin == sizeof_PUZZ

DataX_MountainBonus_puzz:
    .begin
    DB R_KOP, R_KST, R_KS3, R_KS3, R_KS3, R_KS3, R_KS3, R_KS3, R_KST, R_KOP
    D_ANIM $24, DIRF_SOUTH
    DB R_KOP, R_KOP, O_CW3, G_CHS, O_EMP, W_RCK, O_EMP, O_EMP, R_KW3, R_KST
    D_ANIM $60, DIRF_SOUTH
    DB R_KST, R_KS3, O_CW3, O_EMP, O_EMP, S_BSH, O_EMP, S_ARN, R_KSW, R_KOP
    D_ANIM $31, DIRF_SOUTH
    DB R_KS3, O_CW3, W_CSW, O_RMD, W_CS3, W_CS3, M_RNA, W_CSE, O_CE3, R_KS3
    D_BPTR DataX_ComingRound_song
    DB W_TTP, O_CW3, O_EMP, O_EMP, O_EMP, S_ARS, O_EMP, G_APL, O_CE3, W_TTP
    D_BPTR DataX_Null_dlog
    DB W_TTR, O_CW3, S_ARE, O_EMP, O_EMP, O_EMP, O_EMP, O_CE3, W_CSE, W_TTR
    D_BPTR DataX_Null_dlog
    DB O_EMP, W_CSW, W_CS3, W_CS3, O_RWL, O_RWR, W_CS3, W_CSE, G_PNT, O_EMP
    D_SETS TILESET_PUZZ_MOUNTAIN, COLORSET_SUMMER
    DB O_EMP, O_EMP, O_GRS, O_EMP, O_EMP, O_EMP, S_ARS, O_EMP, O_EMP, O_EMP
    D_PAR $0999  ; TODO: choose correct par value
    DB O_EMP, O_GRS, W_RCK, O_EMP, S_ARN, O_EMP, O_EMP, O_EMP, S_ARW, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Lake0_puzz:
    .begin
    DB W_TTP, W_TTR, O_EMP, R_RNS, O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP
    D_ANIM $11, DIRF_SOUTH
    DB W_TTR, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP
    D_ANIM $04, DIRF_SOUTH
    DB O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP, O_EMP, O_BNS, O_EMP, O_EMP
    D_ANIM $09, DIRF_SOUTH
    DB O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP
    D_BPTR DataX_TitleMusic_song
    DB O_EMP, O_EMP, O_EMP, R_RNE, R_RSW, O_EMP, O_EMP, R_RNS, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_GRS, O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, R_RSE, R_RNW, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_GRS, O_GRS, O_EMP, O_EMP, O_BNS, O_EMP, R_RNS, O_EMP, O_EMP, O_GRS
    D_SETS TILESET_PUZZ_LAKE, COLORSET_AUTUMN
    DB R_SN3, R_SN3, R_SNE, G_CHS, R_RNS, G_APL, R_RNS, G_PNT, R_SNW, R_SN3
    D_PAR $0038
    DB R_OOP, R_OOP, R_ONE, R_SN3, R_ONN, R_SN3, R_ONN, R_SN3, R_ONW, R_OOP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Lake1_puzz:
    .begin
    DB O_EMP, O_EMP, W_TTR, O_EMP, O_EMP, R_RNE, R_RSW, O_EMP, O_GRS, O_EMP
    D_ANIM $75, DIRF_SOUTH
    DB O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_BNS, O_EMP, O_EMP, O_GRS
    D_ANIM $59, DIRF_WEST
    DB O_EMP, O_EMP, R_RSE, R_REW, R_RSW, O_EMP, R_RNS, O_EMP, G_PNT, O_EMP
    D_ANIM $21, DIRF_EAST
    DB O_EMP, S_BSH, R_RNS, G_APL, R_RNS, O_EMP, R_RNS, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_TitleMusic_song
    DB O_EMP, O_EMP, R_RNE, R_REW, R_RNW, O_EMP, R_RNS, O_EMP, O_GRS, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, W_RCK, O_EMP, O_EMP, O_EMP, O_EMP, R_RNE, R_RSW, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB G_CHS, O_EMP, O_EMP, S_ARW, O_EMP, O_EMP, O_EMP, O_BNS, O_GRS, R_SNW
    D_SETS TILESET_PUZZ_LAKE, COLORSET_AUTUMN
    DB O_GRS, S_BSH, O_GRS, O_GRS, O_EMP, O_EMP, R_SNW, R_ONN, R_SN3, R_ONW
    D_PAR $0037
    DB R_SN3, R_SN3, R_SN3, R_SN3, R_SN3, R_SN3, R_ONW, R_OOP, R_OOP, R_OOP
ASSERT @ - .begin == sizeof_PUZZ

DataX_LakeBonus_puzz:
    .begin
    DB W_TST, W_TTR, O_GRS, O_EMP, O_EMP, W_TTR, O_EMP, O_EMP, W_TST, W_TST
    D_ANIM $07, DIRF_WEST
    DB W_TTR, O_EMP, O_EMP, O_EMP, O_EMP, S_BSH, O_EMP, W_RCK, W_TST, W_TST
    D_ANIM $50, DIRF_EAST
    DB O_EMP, O_EMP, O_EMP, G_CHS, O_EMP, O_EMP, W_RCK, G_APL, W_TTR, W_TST
    D_ANIM $20, DIRF_SOUTH
    DB O_GRS, O_EMP, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_ARW, W_TTR
    D_BPTR DataX_TitleMusic_song
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, R_RSE, R_REW, R_REW, R_REW, R_REW
    D_BPTR DataX_Null_dlog
    DB O_EMP, G_PNT, O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, O_GRS, S_BSH, W_TTP
    D_BPTR DataX_Null_dlog
    DB R_RSE, R_REW, R_REW, O_BEW, R_REW, R_RNW, O_GRS, W_RCK, O_EMP, W_TTR
    D_SETS TILESET_PUZZ_LAKE, COLORSET_WINTER
    DB R_RNW, W_TTP, O_EMP, S_BSH, O_GRS, O_EMP, W_FW1, W_FNS, M_FNS, W_FNS
    D_PAR $0038
    DB W_TTP, W_TST, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, O_EMP, W_RCK
ASSERT @ - .begin == sizeof_PUZZ

DataX_Lake3_puzz:
    .begin
    DB O_EMP, O_EMP, O_EMP, S_BSH, G_CHS, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP
    D_ANIM $06, DIRF_EAST
    DB O_EMP, W_FW1, M_FNS, W_FE1, S_ARS, W_TTR, O_EMP, O_EMP, O_EMP, O_EMP
    D_ANIM $09, DIRF_WEST
    DB O_EMP, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_ARS, O_EMP
    D_ANIM $59, DIRF_WEST
    DB S_BSH, W_TST, O_EMP, S_ARN, G_PNT, O_EMP, O_EMP, O_EMP, O_EMP, R_SNW
    D_BPTR DataX_TitleMusic_song
    DB O_EMP, W_TTR, S_ARE, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, G_APL, R_SSW
    D_BPTR DataX_Null_dlog
    DB O_BEW, R_REW, R_REW, R_REW, R_REW, R_REW, R_RSW, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, W_RCK, O_EMP, O_EMP, O_EMP, O_EMP, R_RNE, R_REW, R_REW, R_REW
    D_SETS TILESET_PUZZ_LAKE, COLORSET_AUTUMN
    DB O_EMP, O_EMP, O_EMP, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_PAR $0033
    DB O_EMP, O_EMP, O_EMP, W_TTR, O_EMP, S_ARN, O_EMP, O_EMP, O_EMP, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Lake4_puzz:
    .begin
    DB R_SS3, R_SS3, R_OSS, R_SS3, R_OSS, R_SSE, O_EMP, R_SSW, R_SS3, R_SS3
    D_ANIM $19, DIRF_SOUTH
    DB O_EMP, O_EMP, R_RNS, O_EMP, R_RNS, O_EMP, O_GRS, W_TTP, O_EMP, O_EMP
    D_ANIM $20, DIRF_EAST
    DB O_EMP, O_EMP, R_RNS, O_GRS, R_RNS, O_EMP, O_EMP, W_TTR, O_EMP, O_GRS
    D_ANIM $18, DIRF_SOUTH
    DB W_FNS, W_FE1, R_RNS, O_EMP, R_RNS, W_FW1, M_FNS, W_FE1, O_EMP, O_EMP
    D_BPTR DataX_TitleMusic_song
    DB O_EMP, G_APL, R_RNS, O_EMP, R_RNS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, R_RNS, O_GRS, R_RNS, O_EMP, O_EMP, G_CHS, O_EMP, G_PNT
    D_BPTR DataX_Null_dlog
    DB O_GRS, O_EMP, R_RNS, O_EMP, R_RNE, R_RSW, O_EMP, O_EMP, O_EMP, O_EMP
    D_SETS TILESET_PUZZ_LAKE, COLORSET_AUTUMN
    DB O_EMP, R_RSE, R_RNW, O_EMP, O_EMP, O_BNS, O_EMP, O_EMP, O_GRS, O_EMP
    D_PAR $0049
    DB O_EMP, R_RNS, O_EMP, O_EMP, O_EMP, R_RNS, O_EMP, O_GRS, O_EMP, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Sewer0_puzz:
    .begin
    DB O_EMP, O_EMP, W_LW3, W_LE3, W_BS3, W_BS3, W_LEW, W_BS3, W_BS3, W_LW3
    D_ANIM $11, DIRF_SOUTH
    DB O_EMP, O_EMP, W_LEW, W_BSE, G_CHS, O_EMP, W_LEW, O_EMP, O_EMP, W_BSW
    D_ANIM $20, DIRF_SOUTH
    DB O_EMP, S_PPW, W_LEW, O_EMP, W_RCK, O_EMP, W_LEW, O_EMP, W_RCK, O_EMP
    D_ANIM $17, DIRF_SOUTH
    DB R_EDG, O_EMP, W_LEW, W_RCK, O_EMP, O_EMP, W_BS1, S_PPE, O_EMP, O_EMP
    D_BPTR DataX_RestYe_song
    DB R_OOP, O_EMP, W_BS1, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Sewer0Intro_dlog
    DB R_OOP, O_EMP, O_EMP, O_EMP, W_RCK, O_EMP, G_APL, O_EMP, W_LN1, O_EMP
    D_BPTR DataX_Null_dlog
    DB R_OOP, R_EDG, R_GRT, O_EMP, G_PNT, O_EMP, O_EMP, O_EMP, W_BS1, O_EMP
    D_SETS TILESET_PUZZ_SEWER, COLORSET_SEWER
    DB R_OOP, R_OOP, R_OOP, O_EMP, O_EMP, O_EMP, R_GRT, O_EMP, O_EMP, O_EMP
    D_PAR $0046
    DB R_OOP, R_OOP, R_OOP, R_EDG, R_EDG, R_EDG, R_OOP, R_EDG, R_EDG, R_EDG
ASSERT @ - .begin == sizeof_PUZZ

DataX_Sewer1_puzz:
    .begin
    DB W_ROP, W_LE3, O_EMP, W_LEW, O_EMP, O_EMP, W_BSW, W_BSE, O_EMP, O_EMP
    D_ANIM $20, DIRF_EAST
    DB W_BS3, W_BSE, O_EMP, W_LEW, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_ANIM $02, DIRF_SOUTH
    DB O_EMP, O_EMP, S_PPW, W_LEW, O_EMP, O_EMP, W_LNW, W_LNE, O_EMP, O_EMP
    D_ANIM $24, DIRF_SOUTH
    DB W_BS3, W_BSE, O_EMP, W_BS1, W_RCK, W_RCK, W_BSW, W_LEW, O_EMP, O_EMP
    D_BPTR DataX_RestYe_song
    DB O_EMP, O_EMP, S_ARE, O_EMP, O_EMP, O_EMP, O_EMP, W_LEW, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, O_EMP, W_BS1, S_PPE, O_EMP, O_EMP, W_LEW, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB G_APL, O_EMP, O_EMP, S_ARS, O_EMP, O_EMP, G_PNT, W_LEW, O_EMP, G_CHS
    D_SETS TILESET_PUZZ_SEWER, COLORSET_SEWER
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_PPW, W_BS1, O_EMP, O_EMP
    D_PAR $0033
    DB R_EDG, O_EMP, S_ARN, O_EMP, S_ARN, O_EMP, O_EMP, R_EDG, R_EDG, R_EDG
ASSERT @ - .begin == sizeof_PUZZ

DataX_Sewer2_puzz:
    .begin
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_ANIM $73, DIRF_SOUTH
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_PPW, W_LN1, O_EMP, O_EMP, W_BSW
    D_ANIM $70, DIRF_EAST
    DB O_EMP, S_PPW, W_LN1, O_EMP, O_EMP, O_EMP, W_LEW, O_EMP, O_EMP, O_EMP
    D_ANIM $57, DIRF_WEST
    DB O_EMP, O_EMP, W_BS1, O_EMP, O_EMP, O_EMP, W_BS1, O_EMP, W_LN1, O_EMP
    D_BPTR DataX_RestYe_song
    DB O_EMP, O_EMP, O_EMP, O_EMP, W_LN1, O_EMP, O_EMP, O_EMP, W_LEW, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, O_EMP, O_EMP, W_LEW, S_PPE, O_EMP, O_EMP, W_LEW, O_EMP
    D_BPTR DataX_Null_dlog
    DB G_PNT, O_EMP, O_EMP, O_EMP, W_BS1, O_EMP, W_BSW, W_BS3, W_BSE, G_APL
    D_SETS TILESET_PUZZ_SEWER, COLORSET_SEWER
    DB O_EMP, O_EMP, O_EMP, O_EMP, R_EDG, O_EMP, G_CHS, O_EMP, R_EDG, R_EDG
    D_PAR $0048
    DB R_EDG, R_EDG, R_GRT, R_EDG, R_OOP, R_EDG, R_EDG, R_EDG, R_OOP, R_OOP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Sewer3_puzz:
    .begin
    DB O_EMP, O_EMP, W_BSW, W_BSE, O_EMP, W_LEW, W_BSE, O_EMP, S_ARS, O_EMP
    D_ANIM $00, DIRF_SOUTH
    DB O_EMP, R_EDG, O_EMP, O_EMP, S_PPW, W_LEW, O_EMP, O_EMP, O_EMP, G_CHS
    D_ANIM $79, DIRF_WEST
    DB O_EMP, R_OOP, S_ARE, O_EMP, O_EMP, W_BSW, M_BNS, W_BSE, O_EMP, O_EMP
    D_ANIM $04, DIRF_SOUTH
    DB O_EMP, R_OOP, O_EMP, G_PNT, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_RestYe_song
    DB O_EMP, R_OOP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, R_OOP, O_EMP, W_LN1, O_EMP, G_APL, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_BNS, S_PPW, W_LEW, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_SETS TILESET_PUZZ_SEWER, COLORSET_SEWER
    DB O_EMP, R_OOP, O_EMP, W_LEW, M_BNS, W_BSE, O_EMP, S_ARN, O_EMP, O_EMP
    D_PAR $0050
    DB O_EMP, R_OOP, O_EMP, W_BS1, O_EMP, O_EMP, O_EMP, W_LNW, W_LN3, W_LNE
ASSERT @ - .begin == sizeof_PUZZ

DataX_SewerBonus_puzz:
    .begin
    DB O_EMP, O_EMP, O_EMP, W_LEW, O_EMP, O_EMP, O_EMP, O_EMP, W_LW3, W_ROP
    D_ANIM $83, DIRF_SOUTH
    DB O_EMP, G_PNT, O_EMP, W_BS1, O_EMP, S_ARS, O_EMP, O_EMP, W_BSW, W_BS3
    D_ANIM $02, DIRF_WEST
    DB O_EMP, O_EMP, O_EMP, S_ARS, O_EMP, O_EMP, W_LN1, O_EMP, O_EMP, O_EMP
    D_ANIM $85, DIRF_SOUTH
    DB O_EMP, O_EMP, W_LN1, O_EMP, O_EMP, O_EMP, W_LEW, S_PPE, S_BSH, O_EMP
    D_BPTR DataX_RestYe_song
    DB O_EMP, S_PPW, W_BS1, O_EMP, O_EMP, O_EMP, W_LEW, O_EMP, W_LN1, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, O_EMP, O_EMP, W_BSW, M_BNS, W_LEW, O_EMP, W_BS1, O_EMP
    D_BPTR DataX_Null_dlog
    DB W_LNE, O_EMP, O_EMP, O_EMP, S_BSH, S_PPW, W_LEW, O_EMP, O_EMP, O_EMP
    D_SETS TILESET_PUZZ_SEWER, COLORSET_SEWER
    DB W_BSE, G_APL, O_EMP, O_EMP, W_LN1, O_EMP, W_LEW, M_BNS, W_BS3, W_BS3
    D_PAR $0112
    DB O_EMP, O_EMP, O_EMP, O_EMP, W_LEW, O_EMP, W_LEW, O_EMP, O_EMP, G_CHS
ASSERT @ - .begin == sizeof_PUZZ

DataX_Sewer5_puzz:
    .begin
    DB W_LE3, G_APL, W_BSW, W_BS3, W_BSE, G_PNT, W_BSW, W_BSE, G_CHS, W_LW3
    D_ANIM $87, DIRF_SOUTH
    DB W_BSE, O_EMP, S_ARS, O_EMP, O_EMP, O_EMP, O_EMP, S_ARS, O_EMP, W_BSW
    D_ANIM $29, DIRF_WEST
    DB O_EMP, O_EMP, O_EMP, O_EMP, S_ARS, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_ANIM $54, DIRF_EAST
    DB O_EMP, S_PPW, W_LN1, O_EMP, O_EMP, O_EMP, O_EMP, W_LN1, O_EMP, O_EMP
    D_BPTR DataX_RestYe_song
    DB O_EMP, O_EMP, W_LW3, W_LNE, W_BSE, S_BSH, W_BSW, W_LEW, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, W_LEW, W_BSE, O_EMP, O_EMP, O_EMP, W_BS1, S_PPE, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, S_PPW, W_BS1, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_SETS TILESET_PUZZ_SEWER, COLORSET_SEWER
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, R_EDG, R_EDG
    D_PAR $0055
    DB O_EMP, O_EMP, W_LN1, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, R_OOP, R_OOP
ASSERT @ - .begin == sizeof_PUZZ

DataX_City0_puzz:
    .begin
    DB W_LNE, W_FNS, W_FNS, W_LC4, W_FNS, W_FNS, W_BSW, W_BSE, W_FNS, W_LNW
    D_ANIM $18, DIRF_SOUTH
    DB W_LE3, O_EMP, O_EMP, W_BS1, S_MTP, O_EMP, O_EMP, O_EMP, O_EMP, W_LW3
    D_ANIM $11, DIRF_SOUTH
    DB W_LE3, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_MTP, W_LW3
    D_ANIM $70, DIRF_EAST
    DB W_LE3, O_EMP, G_APL, W_LC4, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_LW3
    D_BPTR DataX_MarchingHome_song
    DB W_LSE, O_EMP, O_EMP, W_BS1, G_PNT, O_EMP, O_EMP, O_EMP, S_MTP, W_LSW
    D_BPTR DataX_City0Intro_dlog
    DB W_BSE, O_EMP, O_EMP, S_MTP, O_EMP, W_LW1, W_LE1, O_EMP, O_EMP, W_BSW
    D_BPTR DataX_Null_dlog
    DB W_FNS, W_FE1, O_EMP, O_EMP, O_EMP, W_BSW, W_BSE, S_MTP, O_EMP, O_EMP
    D_SETS TILESET_PUZZ_CITY, COLORSET_SEWER
    DB O_EMP, O_EMP, O_EMP, O_EMP, S_MTP, O_EMP, O_EMP, O_EMP, G_CHS, W_LW1
    D_PAR $0047
    DB W_LNW, W_LN3, W_LNE, W_FNS, W_FNS, W_FNS, W_LN1, W_FNS, W_FNS, W_BSW
ASSERT @ - .begin == sizeof_PUZZ

DataX_CityBonus_puzz:
    .begin
    DB W_LW1, W_LE1, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_LW1, W_LNS
    D_ANIM $65, DIRF_SOUTH
    DB W_BSW, W_BSE, M_FNS, W_FNS, W_LC4, W_FNS, W_FNS, M_FNS, W_BSW, W_BS3
    D_ANIM $25, DIRF_SOUTH
    DB O_EMP, O_EMP, O_EMP, O_EMP, W_BS1, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_ANIM $50, DIRF_SOUTH
    DB G_CHS, O_EMP, O_EMP, S_MTP, O_EMP, O_EMP, O_EMP, O_EMP, W_LC4, O_EMP
    D_BPTR DataX_MarchingHome_song
    DB O_EMP, O_EMP, G_APL, O_EMP, W_DMP, O_EMP, G_PNT, O_EMP, W_BS1, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, W_LN1, O_EMP, O_EMP, O_EMP, S_MTP, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB W_LNS, W_LLE, O_EMP, O_EMP, W_LC4, O_EMP, O_EMP, O_EMP, W_LNW, W_LNE
    D_SETS TILESET_PUZZ_CITY, COLORSET_SEWER
    DB W_BS3, W_BSE, M_FNS, W_FNS, W_BS1, W_FNS, W_FNS, M_FNS, W_LSW, W_LSE
    D_PAR $0040
    DB O_EMP, O_EMP, S_MTP, O_EMP, O_EMP, O_EMP, O_EMP, S_MTP, W_BSW, W_BSE
ASSERT @ - .begin == sizeof_PUZZ

DataX_City4_puzz:
    .begin
    DB W_LW1, W_LNS, W_LNS, W_LNS, W_LE1, O_EMP, O_EMP, O_EMP, W_LW1, W_LE1
    D_ANIM $29, DIRF_SOUTH
    DB W_BSW, W_BS3, W_BS3, W_BS3, W_BSE, M_FNS, W_LN1, M_FNS, W_BSW, W_BSE
    D_ANIM $51, DIRF_WEST
    DB O_EMP, O_EMP, S_MTP, O_EMP, O_EMP, S_PPW, W_LEW, O_EMP, O_EMP, O_EMP
    D_ANIM $20, DIRF_EAST
    DB S_ARE, O_EMP, W_LN1, O_EMP, O_EMP, O_EMP, W_LS1, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_MarchingHome_song
    DB O_EMP, O_EMP, W_LEW, O_EMP, G_APL, O_EMP, W_BS1, O_EMP, O_EMP, G_CHS
    D_BPTR DataX_Null_dlog
    DB G_PNT, O_EMP, W_LEW, O_EMP, O_EMP, O_EMP, S_MTP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, S_PPW, W_LS1, O_EMP, O_EMP, O_EMP, R_RS1, O_EMP, O_EMP, S_MTP
    D_SETS TILESET_PUZZ_CITY, COLORSET_SEWER
    DB W_LE1, M_FNS, W_BS1, M_FNS, W_FNS, W_FE1, R_RNS, W_LW1, W_LNS, W_LE1
    D_PAR $0055
    DB W_BSE, O_EMP, O_EMP, O_EMP, R_RSE, R_REW, R_RNW, W_BSW, W_BS3, W_BSE
ASSERT @ - .begin == sizeof_PUZZ

DataX_City1_puzz:
    .begin
    DB O_EMP, O_EMP, W_BSW, W_BSE, O_EMP, O_EMP, G_CHS, G_APL, O_EMP, O_EMP
    D_ANIM $09, DIRF_SOUTH
    DB O_EMP, S_ARE, O_EMP, O_EMP, S_ARS, O_EMP, W_LW1, W_LE1, O_EMP, O_EMP
    D_ANIM $86, DIRF_WEST
    DB O_EMP, O_EMP, O_EMP, W_LC4, O_EMP, O_EMP, W_BSW, W_BSE, O_EMP, W_LNW
    D_ANIM $01, DIRF_SOUTH
    DB O_EMP, O_EMP, O_EMP, W_BS1, S_ARS, O_EMP, S_ARW, O_EMP, O_EMP, W_LW3
    D_BPTR DataX_MarchingHome_song
    DB O_EMP, G_PNT, O_EMP, O_EMP, S_MTP, O_EMP, O_EMP, S_ARW, O_EMP, W_LSW
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, O_EMP, W_LC4, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_BSW
    D_BPTR DataX_Null_dlog
    DB W_FNS, M_FNS, W_FNS, W_BS1, M_FNS, W_FE1, O_EMP, S_ARN, O_EMP, O_EMP
    D_SETS TILESET_PUZZ_CITY, COLORSET_SEWER
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_PAR $0037
    DB O_EMP, S_ARE, O_EMP, O_EMP, S_ARN, O_EMP, O_EMP, W_LNW, W_LN3, W_LNE
ASSERT @ - .begin == sizeof_PUZZ

DataX_City2_puzz:
    .begin
    DB S_MTP, O_EMP, O_EMP, W_LN1, G_PNT, W_LN1, W_DMP, O_EMP, O_EMP, W_DMP
    D_ANIM $16, DIRF_EAST
    DB O_EMP, O_EMP, G_CHS, W_LEW, O_EMP, W_LS1, O_EMP, O_EMP, O_EMP, O_EMP
    D_ANIM $11, DIRF_NORTH
    DB M_FNS, W_FE1, O_EMP, W_LS1, O_EMP, W_BS1, M_FNS, W_FE1, S_ARS, W_LW1
    D_ANIM $22, DIRF_SOUTH
    DB O_EMP, O_EMP, S_PPW, W_BS1, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_BSW
    D_BPTR DataX_MarchingHome_song
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_BSH, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, O_EMP, O_EMP, W_LC4, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_SETS TILESET_PUZZ_CITY, COLORSET_SEWER
    DB O_EMP, O_EMP, O_EMP, O_EMP, W_BS1, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_PAR $0052
    DB O_EMP, O_EMP, O_EMP, S_BSH, G_APL, S_MTP, O_EMP, O_EMP, S_MTP, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Space0_puzz:
    .begin
    DB R_OOP, R_OOP, R_OOP, R_OOP, R_OOP, R_OOP, R_OOP, R_OOP, R_OOP, R_OOP
    D_ANIM $51, DIRF_SOUTH
    DB W_LN1, O_EMP, O_EMP, G_CHS, O_EMP, O_EMP, W_LN1, O_EMP, O_EMP, W_LN1
    D_ANIM $17, DIRF_SOUTH
    DB W_LEW, S_TGE, O_EMP, O_EMP, S_TMF, O_EMP, W_LEW, O_EMP, G_APL, W_LEW
    D_ANIM $15, DIRF_WEST, 0, 0, $47, $33
    DB W_LEW, O_EMP, W_LN1, S_TMF, O_EMP, O_EMP, W_LEW, O_EMP, O_EMP, W_LEW
    D_BPTR DataX_LightsOn_song, 0, 0, $24
    DB W_LEW, W_BS3, W_BS3, W_BS3, M_BNS, W_LNW, W_LE3, S_TGE, O_EMP, W_LEW
    D_BPTR DataX_Space0Intro_dlog, 0, $21, 0
    DB W_LEW, O_EMP, O_EMP, O_EMP, O_EMP, W_BSW, W_LEW, O_EMP, O_EMP, W_LEW
    D_BPTR DataX_Null_dlog
    DB W_BS1, G_PNT, O_EMP, S_TEF, O_EMP, O_EMP, W_LEW, O_EMP, O_EMP, W_BS1
    D_SETS TILESET_PUZZ_SPACE, COLORSET_SPACE, 0, 0, 0, $78
    DB R_GDR, O_EMP, O_EMP, O_EMP, O_EMP, W_BW1, W_BSE, O_EMP, S_TEF, R_GDR
    D_PAR $0027, 0, 0, 0, $63
    DB R_OOP, R_GDR, R_GDR, R_GDR, R_GDR, R_GDR, R_GDR, R_GDR, R_GDR, R_OOP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Space3_puzz:
    .begin
    DB O_EMP, S_TME, O_EMP, S_MTP, O_EMP, S_TEF, O_EMP, O_EMP, O_EMP, S_MTP
    D_ANIM $00, DIRF_SOUTH, 0, 0, $36, $75
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_LN1, S_MTP, W_BW1, W_LN1, O_EMP
    D_ANIM $80, DIRF_SOUTH
    DB O_EMP, W_BW1, W_LN1, O_EMP, G_CHS, W_LEW, O_EMP, O_EMP, W_LEW, G_PNT
    D_ANIM $07, DIRF_WEST
    DB O_EMP, O_EMP, W_LEW, O_EMP, O_EMP, W_BS1, S_TME, O_EMP, W_LEW, O_EMP
    D_BPTR DataX_LightsOn_song, 0, $01, 0
    DB S_ARS, O_EMP, W_LEW, S_ARE, O_EMP, O_EMP, W_BW1, W_BS3, W_BSE, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, W_LEW, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB R_GDR, O_EMP, W_LEW, O_EMP, R_GDR, R_GDR, R_GDR, R_GDR, R_GDR, R_GDR
    D_SETS TILESET_PUZZ_SPACE, COLORSET_SPACE
    DB O_EMP, O_EMP, W_BS1, O_EMP, O_EMP, S_TEF, O_EMP, O_EMP, O_EMP, S_ARW
    D_PAR $0054, 0, 0, 0, $05
    DB O_EMP, O_EMP, O_EMP, O_EMP, G_APL, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Space2_puzz:
    .begin
    DB O_EMP, W_BSW, W_BS3, W_BSE, O_EMP, O_EMP, W_LEW, R_OOP, R_OOP, R_OOP
    D_ANIM $40, DIRF_EAST
    DB S_TGE, O_EMP, S_BSH, O_EMP, O_EMP, O_EMP, W_LEW, O_EMP, O_EMP, O_EMP
    D_ANIM $17, DIRF_EAST, 0, 0, $79, 0
    DB G_APL, O_EMP, W_LN1, O_EMP, O_EMP, O_EMP, W_LEW, S_PPE, S_TEF, O_EMP
    D_ANIM $89, DIRF_WEST, 0, 0, 0, $75
    DB O_EMP, O_EMP, W_LEW, S_PPE, O_EMP, G_CHS, W_LEW, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_LightsOn_song
    DB O_EMP, O_EMP, W_LEW, O_EMP, O_EMP, O_EMP, W_LEW, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB R_GDR, R_GDR, W_LEW, O_EMP, O_EMP, O_EMP, W_BS1, R_GDR, R_GDR, R_GDR
    D_BPTR DataX_Null_dlog
    DB S_ARE, G_PNT, W_BS1, O_EMP, S_ARN, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_SETS TILESET_PUZZ_SPACE, COLORSET_SPACE
    DB O_EMP, S_MTP, O_EMP, O_EMP, S_ARS, S_TEF, O_EMP, S_ARW, O_EMP, S_TGE
    D_PAR $0066, 0, 0, $10, $28
    DB R_GDR, R_GDR, R_GDR, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

DataX_Space1_puzz:
    .begin
    DB R_OOP, R_OOP, O_EMP, O_EMP, G_CHS, O_EMP, O_EMP, O_EMP, W_BSW, W_BS3
    D_ANIM $79, DIRF_SOUTH
    DB O_EMP, G_PNT, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_ANIM $19, DIRF_WEST
    DB O_EMP, O_EMP, S_TEF, O_EMP, S_BSH, S_ARW, S_BSH, O_EMP, O_EMP, O_EMP
    D_ANIM $43, DIRF_SOUTH, 0, 0, 0, $59
    DB O_EMP, O_EMP, O_EMP, S_BSH, S_ARN, S_TGE, O_EMP, S_BSH, O_EMP, S_TMF
    D_BPTR DataX_LightsOn_song, 0, $53, $41
    DB O_EMP, S_TMF, S_BSH, O_EMP, S_BSH, O_EMP, S_BSH, S_ARW, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, $39
    DB O_EMP, O_EMP, O_EMP, S_TGE, O_EMP, S_BSH, O_EMP, O_EMP, O_EMP, S_TEF
    D_BPTR DataX_Null_dlog, 0, $35, $22
    DB O_EMP, O_EMP, S_BSH, O_EMP, S_BSH, O_EMP, O_EMP, O_EMP, G_APL, O_EMP
    D_SETS TILESET_PUZZ_SPACE, COLORSET_SPACE
    DB W_BE1, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, S_MTP, O_EMP, O_EMP, O_EMP
    D_PAR $0058
    DB S_MTP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, R_GDR, R_GDR, R_GDR
ASSERT @ - .begin == sizeof_PUZZ

DataX_Space4_puzz:
    .begin
    DB O_EMP, R_OOP, O_EMP, O_EMP, W_BS1, O_EMP, O_EMP, O_EMP, O_EMP, R_OOP
    D_ANIM $29, DIRF_SOUTH
    DB O_EMP, S_TME, O_EMP, O_EMP, S_TEF, O_EMP, O_EMP, S_ARN, O_EMP, O_EMP
    D_ANIM $03, DIRF_SOUTH, 0, 0, $76, $55
    DB O_EMP, O_EMP, S_ARS, O_EMP, S_MTP, O_EMP, W_RCK, O_EMP, S_TGE, O_EMP
    D_ANIM $70, DIRF_EAST, 0, 0, $31, 0
    DB O_EMP, S_TGE, O_EMP, O_EMP, O_EMP, R_GDR, O_EMP, G_PNT, O_EMP, W_BW1
    D_BPTR DataX_LightsOn_song, 0, $28, 0
    DB S_MTP, O_EMP, O_EMP, R_GDR, O_EMP, O_EMP, S_BSH, O_EMP, S_ARW, O_EMP
    D_BPTR DataX_Null_dlog
    DB O_EMP, O_EMP, W_LN1, S_PPE, S_BSH, S_TEF, O_EMP, W_LN1, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog, 0, 0, $14
    DB O_EMP, W_BW1, W_BSE, O_EMP, O_EMP, W_BW1, M_BNS, W_BSE, O_EMP, O_EMP
    D_SETS TILESET_PUZZ_SPACE, COLORSET_SPACE
    DB O_EMP, O_EMP, S_MTP, O_EMP, S_ARE, O_EMP, S_TMF, S_BSH, G_CHS, O_EMP
    D_PAR $0999, 0, 0, 0, $11  ; TODO: choose correct par value
    DB R_GDR, O_EMP, O_EMP, G_APL, O_EMP, O_EMP, O_EMP, W_LN1, O_EMP, R_GDR
ASSERT @ - .begin == sizeof_PUZZ

DataX_Space5_puzz:
    .begin
    DB S_MTP, G_CHS, O_EMP, O_EMP, W_LN1, O_EMP, O_EMP, S_TMF, O_EMP, S_MTP
    D_ANIM $89, DIRF_SOUTH, 0, 0, 0, $61
    DB S_ARE, O_EMP, S_TEF, G_PNT, W_LEW, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP
    D_ANIM $15, DIRF_EAST, 0, 0, 0, $76
    DB S_MTP, O_EMP, O_EMP, O_EMP, W_LEW, M_BNS, W_BS3, W_BE1, R_GDR, W_BW1
    D_ANIM $21, DIRF_NORTH
    DB O_EMP, W_BW1, W_BE1, O_EMP, W_LEW, O_EMP, S_MTP, O_EMP, O_EMP, O_EMP
    D_BPTR DataX_LightsOn_song
    DB O_EMP, O_EMP, S_MTP, S_PPW, W_LEW, O_EMP, S_BSH, W_LN1, O_EMP, O_EMP
    D_BPTR DataX_Null_dlog
    DB S_TGE, O_EMP, O_EMP, O_EMP, W_LEW, O_EMP, O_EMP, W_BS1, S_PPE, O_EMP
    D_BPTR DataX_Null_dlog, 0, $69, 0
    DB O_EMP, S_TMF, O_EMP, S_BSH, W_LEW, O_EMP, S_ARS, O_EMP, G_APL, S_TGE
    D_SETS TILESET_PUZZ_SPACE, COLORSET_SPACE, 0, 0, $50, $07
    DB O_EMP, O_EMP, O_EMP, O_EMP, W_BS1, O_EMP, S_TEF, O_EMP, O_EMP, O_EMP
    D_PAR $0099, 0, 0, 0, $12
    DB R_GDR, O_EMP, S_ARN, O_EMP, R_GDR, R_GDR, O_EMP, O_EMP, O_EMP, O_EMP
ASSERT @ - .begin == sizeof_PUZZ

;;;=========================================================================;;;
