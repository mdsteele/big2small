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

D_ENV: MACRO
    IF (\2) < 0
    DB ((\1) << 4) | ((\2) & $7)
    ELSE
    DB ((\1) << 4) | ((-(\2)) & $f)
    ENDC
ENDM

D_TONE: MACRO
    IF "\1" == "C"
BASE_FREQ = 16.35160
    ELIF "\1" == "C#" || "\1" == "Db"
BASE_FREQ = 17.32391
    ELIF "\1" == "D"
BASE_FREQ = 18.35405
    ELIF "\1" == "D#" || "\1" == "Eb"
BASE_FREQ = 19.44544
    ELIF "\1" == "E"
BASE_FREQ = 20.60172
    ELIF "\1" == "F"
BASE_FREQ = 21.82676
    ELIF "\1" == "F#" || "\1" == "Gb"
BASE_FREQ = 23.12465
    ELIF "\1" == "G"
BASE_FREQ = 24.49971
    ELIF "\1" == "G#" || "\1" == "Ab"
BASE_FREQ = 25.95654
    ELIF "\1" == "A"
BASE_FREQ = 27.50000
    ELIF "\1" == "A#" || "\1" == "Bb"
BASE_FREQ = 29.13524
    ELIF "\1" == "B"
BASE_FREQ = 30.86771
    ELSE
    FAIL "Invalid note: \1"
    ENDC
TONE_FREQ = BASE_FREQ << (\2)
    DW $8000 | ((2048.0 - MUL(DIV(16384.0, TONE_FREQ), 8.0)) >> 16)
ENDM

;;;=========================================================================;;;

SECTION "SoundData", ROMX

DataX_ArrowTerrain_sfx1::
    DB 5
    DB %00000000  ; sweep
    DB %10000000  ; len
    DB %11110001  ; env
    DB %01000000  ; low
    DB %10000110  ; high
    DB 10
    DB %00000000  ; sweep
    DB %01000000  ; len
    DB %11110001  ; env
    DB %11011100  ; low
    DB %10000101  ; high
    DB 0

DataX_BackToMap_sfx4::
    REPT 3
    DB 13
    DB %00000000  ; len
    DB %10000001  ; env
    DB %00110100  ; poly
    DB %10000000  ; go
    ENDR
    DB 0

DataX_CannotMove_sfx1::
    DB 10
    DB %00101101  ; sweep
    DB %10010000  ; len
    DB %11000010  ; env
    DB %11000000  ; low
    DB %10000111  ; high
    DB 0

DataX_DrawPuzzleNode_sfx1::
    DB 10
    DB $24  ; sweep
    DB $80  ; len
    DB $e1  ; env
    DB $7e  ; low
    DB $84  ; high
    DB 0

DataX_DrawPuzzleTrail_sfx1::
    DB 10
    DB $23  ; sweep
    DB $80  ; len
    DB $b1  ; env
    DB $1a  ; low
    DB $84  ; high
    DB 0

DataX_EatBush_sfx4::
    DB 8
    DB %00000000  ; len
    DB %01011010  ; env
    DB %01000111  ; poly
    DB %10000000  ; go
    DB 18
    DB %00000000  ; len
    DB %11000010  ; env
    DB %00000100  ; poly
    DB %10000000  ; go
    DB 0

DataX_EnterPipe_sfx1::
    REPT 5
    DB 16
    DB %01110011  ; sweep
    DB %10000000  ; len
    DB %11110111  ; env
    DB %11000000  ; low
    DB %10000011  ; high
    ENDR
    DB 24
    DB %01110011  ; sweep
    DB %10000000  ; len
    DB %11110111  ; env
    DB %11000000  ; low
    DB %10000011  ; high
    DB 0

DataX_EnterPuzzle_sfx1::
    DB 4
    DB %00000000  ; sweep
    DB %10000000  ; len
    D_ENV 14, -7
    D_TONE G, 4
    DB 4
    DB %00000000  ; sweep
    DB %10000000  ; len
    D_ENV 14, -7
    D_TONE D, 5
    DB 12
    DB %00000000  ; sweep
    DB %10000000  ; len
    D_ENV 14, -6
    D_TONE G, 5
    DB 0

DataX_LaunchShip_sfx4::
    DB 12
    DB %00000000  ; len
    DB %11110110  ; env
    DB %01110001  ; poly
    DB %10000000  ; go
    DB 12
    DB %00000000  ; len
    DB %11010110  ; env
    DB %01110010  ; poly
    DB %10000000  ; go
    DB 39
    DB %00000000  ; len
    DB %10110101  ; env
    DB %01110011  ; poly
    DB %10000000  ; go
    DB 0

DataX_Leap_sfx1::
    DB 14
    DB %01110101  ; sweep
    DB %01000000  ; len
    DB %11110010  ; env
    DB %11001001  ; low
    DB %10000101  ; high
    DB 0

DataX_EnterArea_sfx1::
DataX_MenuConfirm_sfx1::
    DB 10
    DB $73  ; sweep
    DB $80  ; len
    DB $f1  ; env
    DB $cc  ; low
    DB $85  ; high
    DB 0

DataX_MenuMove_sfx1::
    DB 4
    DB $70  ; sweep
    DB $80  ; len
    DB $c1  ; env
    DB $04  ; low
    DB $86  ; high
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

DataX_Teleport_sfx4::
    DB 6
    DB %00000000  ; len
    DB %11110011  ; env
    DB %01001001  ; poly
    DB %10000000  ; go
    DB 22
    DB %00000000  ; len
    DB %11100010  ; env
    DB %01001010  ; poly
    DB %10000000  ; go
    DB 0

DataX_TitleCrash_sfx4::
    DB 28
    DB %00000000  ; len
    DB %10000011  ; env
    DB %01100001  ; poly
    DB %10000000  ; go
    DB 0

DataX_VictoryNoPar_sfx1::
    DB 4
    DB %00000000  ; sweep
    DB %10000000  ; len
    D_ENV 15, -7
    D_TONE G, 4
    DB 4
    DB %00000000  ; sweep
    DB %10000000  ; len
    D_ENV 15, -7
    D_TONE B, 4
    DB 4
    DB %00000000  ; sweep
    DB %10000000  ; len
    D_ENV 15, -7
    D_TONE D, 5
    DB 32
    DB %00000000  ; sweep
    DB %10000000  ; len
    D_ENV 15, -5
    D_TONE G, 5
    DB 0

DataX_VictoryPar_sfx1::
    DB 8
    DB %00000000  ; sweep
    DB %10000000  ; len
    D_ENV 15, -7
    D_TONE D, 5
    DB 8
    DB %00000000  ; sweep
    DB %10000000  ; len
    D_ENV 15, -7
    D_TONE B, 4
    DB 8
    DB %00000000  ; sweep
    DB %10000000  ; len
    D_ENV 15, -7
    D_TONE G, 4
    DB 8
    DB %00000000  ; sweep
    DB %10000000  ; len
    D_ENV 15, -7
    D_TONE D, 5
    DB 32
    DB %00000000  ; sweep
    DB %10000000  ; len
    D_ENV 15, -5
    D_TONE G, 5
    DB 0

;;;=========================================================================;;;
