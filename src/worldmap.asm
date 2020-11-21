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

;;;=========================================================================;;;

SECTION "WorldMapState", WRAM0

Ram_CurrentPuzzleNumber_u8::
    DB

;;;=========================================================================;;;

SECTION "MainWorldMapScreen", ROM0

;;; @prereq LCD is off.
;;; @param c 1 if current puzzle was just solved, 0 otherwise.
Main_WorldMapScreen::
    ld hl, Ram_CurrentPuzzleNumber_u8
    ld a, c
    or a
    jr z, .notSolved
    inc [hl]
    .notSolved
    ld c, [hl]  ; current puzzle number
    jp Main_BeginPuzzle

;;;=========================================================================;;;
