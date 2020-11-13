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

Data_Puzzle0_puzz::
    DB $00, $01, $01, $00, $00, $00, $00, $00, $00, $00
    DB $11, $22, $32, 0, 0, 0
    DB $01, $00, $00, $01, $00, $00, $00, $00, $00, $00
    DS 6
    DB $01, $00, $00, $00, $01, $00, $01, $00, $00, $00
    DS 6
    DB $00, $01, $00, $00, $00, $01, $00, $00, $00, $00
    DS 6
    DB $00, $00, $00, $00, $00, $00, $00, $01, $01, $01
    DS 6
    DB $00, $00, $00, $00, $00, $00, $00, $01, $00, $00
    DS 6
    DB $02, $00, $02, $00, $02, $00, $00, $01, $01, $01
    DS 6
    DB $02, $02, $02, $00, $02, $00, $00, $00, $00, $01
    DS 6
    DB $02, $00, $02, $00, $02, $00, $00, $01, $01, $01
    DS 6
ASSERT @ - Data_Puzzle0_puzz == sizeof_PUZZ

;;;=========================================================================;;;
