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

SECTION "PuzzleData", ROM0, ALIGN[4]

Data_Puzzle0_puzz:
    DB $3c, $38, $38, $01, $38, $38, $00, $38, $3c, $3c
    DB $17, $71, $58, 0, 0, 0
    DB $3c, $04, $00, $00, $01, $00, $00, $00, $3c, $3c
    DS 6
    DB $3c, $34, $32, $33, $31, $00, $32, $31, $38, $3c
    DS 6
    DB $3c, $38, $30, $00, $00, $00, $00, $00, $06, $3c
    DS 6
    DB $3c, $32, $31, $00, $32, $33, $33, $33, $31, $3c
    DS 6
    DB $3c, $01, $01, $00, $00, $00, $05, $34, $00, $3c
    DS 6
    DB $3c, $01, $00, $00, $01, $00, $30, $38, $01, $3c
    DS 6
    DB $3c, $00, $34, $01, $00, $00, $00, $01, $01, $3c
    DS 6
    DB $3c, $34, $3c, $34, $34, $00, $00, $34, $34, $3c
    DS 6
ASSERT @ - Data_Puzzle0_puzz == sizeof_PUZZ

Data_Puzzle1_puzz:
    DB $3c, $3c, $3c, $3c, $01, $38, $3c, $38, $3c, $3c
    DB $63, $62, $61, 0, 0, 0
    DB $3c, $3c, $38, $38, $00, $00, $38, $00, $3c, $3c
    DS 6
    DB $3c, $3c, $32, $33, $33, $33, $33, $31, $38, $3c
    DS 6
    DB $3c, $38, $34, $00, $00, $00, $00, $30, $00, $38
    DS 6
    DB $3c, $34, $3c, $00, $01, $01, $00, $00, $34, $34
    DS 6
    DB $3c, $38, $38, $30, $00, $01, $00, $30, $38, $3c
    DS 6
    DB $3c, $01, $00, $00, $01, $00, $04, $05, $06, $3c
    DS 6
    DB $38, $00, $34, $34, $00, $00, $34, $34, $34, $3c
    DS 6
    DB $34, $00, $38, $3c, $34, $34, $3c, $3c, $3c, $3c
    DS 6
ASSERT @ - Data_Puzzle1_puzz == sizeof_PUZZ

Data_Puzzle2_puzz:
    DB $3c, $38, $38, $38, $38, $38, $38, $38, $38, $3c
    DB $11, $20, $31, 0, 0, 0
    DB $38, $01, $00, $01, $00, $00, $00, $00, $01, $3c
    DS 6
    DB $00, $00, $00, $00, $01, $00, $01, $00, $00, $3c
    DS 6
    DB $34, $01, $01, $00, $00, $34, $00, $00, $30, $3c
    DS 6
    DB $38, $34, $32, $33, $31, $38, $30, $00, $01, $3c
    DS 6
    DB $34, $38, $00, $00, $04, $00, $00, $01, $01, $3c
    DS 6
    DB $3c, $01, $05, $00, $00, $32, $33, $33, $31, $3c
    DS 6
    DB $3c, $01, $01, $34, $00, $00, $00, $00, $06, $3c
    DS 6
    DB $3c, $34, $01, $3c, $34, $34, $34, $34, $34, $3c
    DS 6
ASSERT @ - Data_Puzzle2_puzz == sizeof_PUZZ

;;;=========================================================================;;;

SECTION "PuzzlePtrs", ROM0

Data_PuzzlePtrs_start::
    DW Data_Puzzle0_puzz
    DW Data_Puzzle1_puzz
    DW Data_Puzzle2_puzz

;;;=========================================================================;;;
