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

SECTION "PuzzleData", ROM0

Data_Puzzle0_puzz:
    DB W_TST, W_TTR, W_TTR, O_GRS, W_TTR, W_TTR, O_EMP, W_TTR, W_TST, W_TST
    DB $17, DIRF_WEST, 0, 0, 0, 0
    DB W_TST, G_PNT, O_EMP, O_EMP, O_GRS, O_EMP, O_EMP, O_EMP, W_TST, W_TST
    DB $71, DIRF_SOUTH, 0, 0, 0, 0
    DB W_TST, W_TTP, W_FLT, W_FMD, W_FRT, O_EMP, W_FLT, W_FRT, W_TTR, W_TST
    DB $58, DIRF_SOUTH, 0, 0, 0, 0
    DB W_TST, W_TTR, W_RCK, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, G_CHS, W_TST
    DS 6
    DB W_TST, W_FLT, W_FRT, O_EMP, W_FLT, W_FMD, W_FMD, W_FMD, W_FRT, W_TST
    DS 6
    DB W_TST, O_GRS, O_GRS, O_EMP, O_EMP, O_EMP, G_APL, W_TTP, O_EMP, W_TST
    DS 6
    DB W_TST, O_GRS, O_EMP, O_EMP, O_GRS, O_EMP, W_RCK, W_TTR, O_GRS, W_TST
    DS 6
    DB W_TST, O_EMP, W_TTP, O_GRS, O_EMP, O_EMP, O_EMP, O_GRS, O_GRS, W_TST
    DS 6
    DB W_TST, W_TTP, W_TST, W_TTP, W_TTP, O_EMP, O_EMP, W_TTP, W_TTP, W_TST
ASSERT @ - Data_Puzzle0_puzz == sizeof_PUZZ

Data_Puzzle1_puzz:
    DB W_TST, W_TST, W_TST, W_TST, O_GRS, W_TTR, W_TST, W_TTR, W_TST, W_TST
    DB $63, DIRF_EAST, 0, 0, 0, 0
    DB W_TST, W_TST, W_TTR, W_TTR, O_EMP, O_EMP, W_TTR, O_EMP, W_TST, W_TST
    DB $62, DIRF_EAST, 0, 0, 0, 0
    DB W_TST, W_TST, W_FLT, W_FMD, W_FMD, W_FMD, W_FMD, W_FRT, W_TTR, W_TST
    DB $61, DIRF_EAST, 0, 0, 0, 0
    DB W_TST, W_TTR, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, W_RCK, O_EMP, W_TTR
    DS 6
    DB W_TST, W_TTP, W_TST, O_EMP, O_GRS, O_GRS, O_EMP, O_EMP, W_TTP, W_TTP
    DS 6
    DB W_TST, W_TTR, W_TTR, W_RCK, O_EMP, O_GRS, O_EMP, W_RCK, W_TTR, W_TST
    DS 6
    DB W_TST, O_GRS, O_EMP, O_EMP, O_GRS, O_EMP, G_PNT, G_APL, G_CHS, W_TST
    DS 6
    DB W_TTR, O_EMP, W_TTP, W_TTP, O_EMP, O_EMP, W_TTP, W_TTP, W_TTP, W_TST
    DS 6
    DB W_TTP, O_EMP, W_TTR, W_TST, W_TTP, W_TTP, W_TST, W_TST, W_TST, W_TST
ASSERT @ - Data_Puzzle1_puzz == sizeof_PUZZ

Data_Puzzle2_puzz:
    DB W_TST, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TTR, W_TST
    DB $11, DIRF_EAST, 0, 0, 0, 0
    DB W_TTR, O_GRS, O_EMP, O_GRS, O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, W_TST
    DB $20, DIRF_EAST, 0, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_GRS, O_EMP, O_GRS, O_EMP, O_EMP, W_TST
    DB W_FRT, DIRF_EAST, 0, 0, 0, 0
    DB W_TTP, O_GRS, O_GRS, O_EMP, O_EMP, W_TTP, O_EMP, O_EMP, W_RCK, W_TST
    DS 6
    DB W_TTR, W_TTP, W_FLT, W_FMD, W_FRT, W_TTR, W_RCK, O_EMP, O_GRS, W_TST
    DS 6
    DB W_TTP, W_TTR, O_EMP, O_EMP, G_PNT, O_EMP, O_EMP, O_GRS, O_GRS, W_TST
    DS 6
    DB W_TST, O_GRS, G_APL, O_EMP, O_EMP, W_FLT, W_FMD, W_FMD, W_FRT, W_TST
    DS 6
    DB W_TST, O_GRS, O_GRS, W_TTP, O_EMP, O_EMP, O_EMP, O_EMP, G_CHS, W_TST
    DS 6
    DB W_TST, W_TTP, O_GRS, W_TST, W_TTP, W_TTP, W_TTP, W_TTP, W_TTP, W_TST
ASSERT @ - Data_Puzzle2_puzz == sizeof_PUZZ

Data_Puzzle3_puzz:
    DB W_CSO, W_CSO, W_CSO, W_CSO, W_CSO, W_CSO, W_CSO, W_CSO, W_CSO, W_CSO
    DB $11, DIRF_SOUTH, 0, 0, 0, 0
    DB W_BLD, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_BLD, W_BLD
    DB $20, DIRF_SOUTH, 0, 0, 0, 0
    DB O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, O_EMP, W_BLD, W_BLD
    DB $31, DIRF_SOUTH, 0, 0, 0, 0
    DB W_BLD, O_EMP, O_EMP, O_EMP, O_EMP, W_BLD, O_EMP, O_EMP, W_BLD, W_BLD
    DS 6
    DB W_CSO, W_CRV, O_RMD, W_CSO, M_RNA, W_CSO, O_RWL, O_RWR, W_CSO, W_CRV
    DS 6
    DB O_EMP, M_RNS, O_EMP, O_EMP, G_PNT, O_EMP, O_EMP, O_EMP, O_EMP, W_RNS
    DS 6
    DB O_EMP, W_RNS, G_APL, O_EMP, O_EMP, W_BLD, W_BLD, W_BLD, W_BLD, W_RNS
    DS 6
    DB O_EMP, W_RSO, O_EMP, W_BLD, O_EMP, O_EMP, O_EMP, O_EMP, G_CHS, W_RSO
    DS 6
    DB W_CSO, W_CSO, W_CSO, W_CSO, W_CSO, W_CSO, W_CSO, W_CSO, W_CSO, W_CSO
ASSERT @ - Data_Puzzle3_puzz == sizeof_PUZZ

;;;=========================================================================;;;

SECTION "PuzzlePtrs", ROM0

Data_PuzzlePtrs_start::
    DW Data_Puzzle0_puzz
    DW Data_Puzzle1_puzz
    DW Data_Puzzle2_puzz
    DW Data_Puzzle3_puzz

;;;=========================================================================;;;
