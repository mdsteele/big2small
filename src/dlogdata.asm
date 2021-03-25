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

;;;=========================================================================;;;

DataX_Forest0Intro_dlog::
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Hi, my name is\n"
    DB "Elle! I wish\n"
    DB "I had a peanut.\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Hey, I think I\n"
    DB "see a peanut up\n"
    DB "ahead there!\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Please use the\n"
    DB "D-pad to take\n"
    DB "me there!\r"
    DB DIALOG_END

DataX_Forest0Outro_dlog::
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "This peanut is\n"
    DB "so delicious.\n"
    DB "Thank you!\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "I'm going to go\n"
    DB "look for more!\r"
    DB DIALOG_END

;;;=========================================================================;;;

DataX_Forest1Intro_dlog::
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Hi there, my\n"
    DB "name's Gisele.\n"
    DB "What's yours?\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "I'm Elle! Are\n"
    DB "you looking for\n"
    DB "peanuts too?\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "I think I'd\n"
    DB "rather eat\n"
    DB "that apple.\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Okay! Let's eat\n"
    DB "once we've both\n"
    DB "got our food.\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Press A or B to\n"
    DB "change which of\n"
    DB "us is selected!\r"
    DB DIALOG_END

DataX_Forest1Outro_dlog::
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Mmm, this apple\n"
    DB "is very...\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "...APPealing!\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "We make a good\n"
    DB "team!  Let's\n"
    DB "be friends!\r"
    DB DIALOG_END

;;;=========================================================================;;;

DataX_Forest2Intro_dlog::
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "A new friend!\n"
    DB "Hi! We're Elle\n"
    DB "and Gisele.\r"
    DB DIALOG_MOUSE
    DB "Hello. My name\n"
    DB "is Mel.\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "We're looking\n"
    DB "for some food.\n"
    DB "What about you?\r"
    DB DIALOG_MOUSE
    DB "I'm looking for\n"
    DB "a spaceship to\n"
    DB "go to the moon.\r"
    DB DIALOG_MOUSE
    DB "...But in the\n"
    DB "meantime I want\n"
    DB "some cheese.\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Great, then we\n"
    DB "can all work\n"
    DB "together!\r"
    DB DIALOG_END

DataX_Forest2Outro_dlog::
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Ahh, nothing\n"
    DB "like good food!\n"
    DB "Let's get more!\r"
    DB DIALOG_MOUSE
    DB "Okay.  But I\n"
    DB "still want\n"
    DB "that spaceship.\r"
    DB DIALOG_END

;;;=========================================================================;;;

DataX_Forest3Intro_dlog::
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "The game might\n"
    DB "start getting\n"
    DB "harder now...\r"
    DB DIALOG_MOUSE
    DB "But what if we\n"
    DB "want to start\n"
    DB "over?\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "We can always\n"
    DB "press START to\n"
    DB "open the menu!\r"
    DB DIALOG_END

;;;=========================================================================;;;
