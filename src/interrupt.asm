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

SECTION "InterruptVBlank", ROM0[$0040]
    push af
    ld a, 1
    ldh [Hram_VBlank_bool], a
    pop af
    reti

SECTION "InterruptStat", ROM0[$0048]
    push af
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_WINON | LCDCF_WIN9C00
    ldh [rLCDC], a
    pop af
    reti

SECTION "InterruptTimer", ROM0[$0050]
    reti

SECTION "InterruptSerial", ROM0[$0058]
    reti

SECTION "InterruptJoypad", ROM0[$0060]
    reti

;;;=========================================================================;;;

SECTION "InterruptState", HRAM
Hram_VBlank_bool::
    DB

;;;=========================================================================;;;
