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

INCLUDE "src/charmap.inc"
INCLUDE "src/dialog.inc"

;;;=========================================================================;;;

CHARMAP "\n", DIALOG_TEXT_NEWLINE
CHARMAP "\r", DIALOG_TEXT_EOF

;;;=========================================================================;;;

SECTION "DialogData", ROMX

DataX_Null_dlog::
    DB DIALOG_END

DataX_Intro_dlog::
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Boy, am I ever\n"
    DB "hungry. I wish\n"
    DB "I had a peanut!\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "I could use an\n"
    DB "apple, myself.\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Sounds great!\r"
    DB DIALOG_MOUSE
    DB "Don't forget\n"
    DB "me! I want some\n"
    DB "cheese!\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "Sounds like a\n"
    DB "party, then!\r"
    DB DIALOG_END

DataX_Outro_dlog::
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "This peanut is\n"
    DB "delicious!\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "Let's go find\n"
    DB "more food!\r"
    DB DIALOG_END

;;;=========================================================================;;;
