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

SECTION "SoundData", ROMX

DataX_CannotMove_sfx1::
    DB 10
    DB %00101101  ; sweep
    DB %10010000  ; len
    DB %11000010  ; env
    DB %11000000  ; low
    DB %10000111  ; high
    DB 0

DataX_Mousetrap_sfx4::
    DB 24
    DB %00000000  ; len
    DB %11110010  ; env
    DB %01010011  ; poly
    DB %10000000  ; go
    DB 0

DataX_PushPipe_sfx4::
    DB 16
    DB %00000000  ; len
    DB %11110011  ; env
    DB %01110000  ; poly
    DB %10000000  ; go
    DB 10
    DB %00000000  ; len
    DB %11110001  ; env
    DB %10000000  ; poly
    DB %10000000  ; go
    DB 0

;;;=========================================================================;;;
