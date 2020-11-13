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

SECTION "Songs", ROM0

Data_TitleMusic_song::
    DW .instTable
    DW .sectTable
    ;; Opcodes:
    DB %01000000  ; SETF to flag=0
    DB %10000000  ; PLAY section 0
    DB %01000010  ; BFEQ by 2 if flag=0
    DB %10000001  ; PLAY section 1
    DB %10000010  ; PLAY section 2
    DB %11000000  ; SETF to flag=1
    DB %00111100  ; JUMP by -4
    .instTable
    ;; Instrument 0 (for ch1/ch2):
    DB %10100011  ; envelope
    DB %00000000  ; sweep
    DB %10000000  ; duty
    DB %00000000  ; ignored
    ;; Instrument 1 (for ch1/ch2):
    DB %10100011  ; envelope
    DB %00000000  ; sweep
    DB %00000000  ; duty
    DB %00000000  ; ignored
    ;; Instrument 2 (for ch4):
    DB %11110001  ; envelope
    DB %00000000  ; poly
    DB %00000000  ; ignored
    DB %00000000  ; ignored
    ;; Instrument 3 (for ch3):
    DB %00100000     ; level
    DB %00000000     ; ignored
    DW .trumpetWave  ; wave ptr
    .trumpetWave
    DB $46, $89, $a9, $89, $a9, $89, $a9, $89
    DB $ab, $cd, $ef, $ec, $a8, $64, $20, $02
    .sectTable
    ;; Section 0:
    DW .sect0ch1
    DW .sect0ch2
    DW .sect0ch3
    DW .sect0ch4
    ;; Section 1:
    DW .sect1ch1
    DW .sect1ch2
    DW .sect1ch3
    DW .sect1ch4
    ;; Section 2:
    DW .sect2ch1
    DW .sect2ch2
    DW .sect2ch3
    DW .sect2ch4
    .sect0ch1
    DB $80 | 0  ; INST
    DB 0        ; HALT
    .sect0ch2
    DB $80 | 1  ; INST
    DB 0        ; HALT
    .sect0ch3
    DB $80 | 3  ; INST
    DB 0        ; HALT
    .sect0ch4
    DB $80 | 2  ; INST
    DB 0        ; HALT
    .sect1ch1
    DB $c0 | HIGH(1046), LOW(1046), 24  ; TONE
    DB 24                               ; REST
    DB $e0 | HIGH(1546), LOW(1546)      ; SAME
    DB 0                                ; HALT
    .sect2ch1
    DB $c0 | HIGH(1546), LOW(1546), 24  ; TONE
    DB 24                               ; REST
    DB $e0 | HIGH(1046), LOW(1046)      ; SAME
    DB 0                                ; HALT
    .sect1ch2
    DB $c0 | HIGH(1798), LOW(1798), 12  ; TONE
    DB $e0 | HIGH(1825), LOW(1825)      ; SAME
    DB $e0 | HIGH(1849), LOW(1849)      ; SAME
    DB $e0 | HIGH(1860), LOW(1860)      ; SAME
    DB $c0 | HIGH(1881), LOW(1881), 36  ; TONE
    DB $c0 | HIGH(1899), LOW(1899), 12  ; TONE
    DB 0                                ; HALT
    .sect2ch2
    DB $c0 | HIGH(1881), LOW(1881), 12  ; TONE
    DB $e0 | HIGH(1860), LOW(1860)      ; SAME
    DB $e0 | HIGH(1849), LOW(1849)      ; SAME
    DB $e0 | HIGH(1825), LOW(1825)      ; SAME
    DB $c0 | HIGH(1798), LOW(1798), 36  ; TONE
    DB 12                               ; REST
    DB 0                                ; HALT
    .sect2ch3
    DB $c0 | HIGH(1881), LOW(1881), 24  ; TONE
    DB 0        ; HALT
    .sect1ch3
    DB $c0 | HIGH(1881), LOW(1881), 24  ; TONE
    DB $e0 | HIGH(1860), LOW(1860)      ; SAME
    DB $e0 | HIGH(1849), LOW(1849)      ; SAME
    DB $e0 | HIGH(1860), LOW(1860)      ; SAME
    DB 0        ; HALT
    .sect1ch4
    .sect2ch4
    DB $c0, 24  ; TONE
    DB $e0      ; SAME
    DB $e0      ; SAME
    DB $e0      ; SAME
    DB 0        ; HALT

;;;=========================================================================;;;
