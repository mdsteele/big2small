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

SECTION "NullDialog", ROMX

DataX_Null_dlog::
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Forest0Dialog", ROMX

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

SECTION "Forest1Dialog", ROMX

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
    DB "Actually, I'm\n"
    DB "looking for a\n"
    DB "tasty apple.\r"
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
    DB "team! Let's be\n"
    DB "friends!\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Forest2Dialog", ROMX

DataX_Forest2Intro_dlog::
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "A new friend!\n"
    DB "Hi! We're Elle\n"
    DB "and Gisele.\r"
    DB DIALOG_MOUSE
    DB "Hello. My name\n"
    DB "is Melanie. Or\n"
    DB "Mel for short.\r"
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
    DB "Okay. But I\n"
    DB "still want that\n"
    DB "spaceship.\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Forest3Dialog", ROMX

DataX_Forest3Intro_dlog::
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "The game might\n"
    DB "start getting\n"
    DB "harder now...\r"
    DB DIALOG_MOUSE
    DB "But what if we\n"
    DB "want to 'start'\n"
    DB "over?\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "We can always\n"
    DB "press START to\n"
    DB "open the menu!\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Forest4Dialog", ROMX

DataX_Forest4Intro_dlog::
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Huh? All these\n"
    DB "shrubs are in\n"
    DB "our way!\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "I can eat them!\n"
    DB "That will clear\n"
    DB "away the path.\r"
    DB DIALOG_MOUSE
    DB "I thought you\n"
    DB "ate apples,\n"
    DB "Gisele.\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Oh sure, for\n"
    DB "dessert.\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "But a girl's\n"
    DB "gotta eat her\n"
    DB "vegetables too!\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Forest6Dialog", ROMX

DataX_Forest6Intro_dlog::
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Did you notice\n"
    DB "the 'Par' in\n"
    DB "the START menu?\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Yeah, what is\n"
    DB "that number\n"
    DB "for, anyway?\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "Winning in that\n"
    DB "many moves gets\n"
    DB "us *stars*!\r"
    DB DIALOG_MOUSE
    DB "Sometimes it\n"
    DB "also unlocks\n"
    DB "bonus puzzles.\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Fun! Let's use\n"
    DB "as few moves as\n"
    DB "we can, then!\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Farm0Dialog", ROMX

DataX_Farm0Intro_dlog::
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "A farm! There's\n"
    DB "bound to be\n"
    DB "good food here.\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "But there's all\n"
    DB "these fences in\n"
    DB "our way!\r"
    DB DIALOG_MOUSE
    DB "I could get in\n"
    DB "through those\n"
    DB "mouse holes...\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "Perfect, Mel,\n"
    DB "that would help\n"
    DB "a HOLE lot!\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Mountain0Dialog", ROMX

DataX_Mountain0Intro_dlog::
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Ahh, just smell\n"
    DB "all that fresh\n"
    DB "mountain air!\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Hey, what are\n"
    DB "all these\n"
    DB "arrows for?\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Trail markers!\n"
    DB "They help us go\n"
    DB "the right way.\r"
    DB DIALOG_MOUSE
    DB "They...don't\n"
    DB "seem very\n"
    DB "helpful.\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Oh well, let's\n"
    DB "just try\n"
    DB "following them!\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Mountain3Dialog", ROMX

DataX_Mountain3Intro_dlog::
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "We're so high\n"
    DB "up! What a\n"
    DB "great view!\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "It almost feels\n"
    DB "like we could\n"
    DB "touch the moon!\r"
    DB DIALOG_MOUSE
    DB "Nope. We need a\n"
    DB "spaceship to do\n"
    DB "that.\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Right, weren't\n"
    DB "you looking for\n"
    DB "one of those?\r"
    DB DIALOG_MOUSE
    DB "Yes. I want to\n"
    DB "be the first\n"
    DB "mouse-tronaut.\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Lake0Dialog", ROMX

DataX_Lake0Intro_dlog::
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "I guess we've\n"
    DB "got some rivers\n"
    DB "to cross!\r"
    DB DIALOG_MOUSE
    DB "I don't really\n"
    DB "want to get my\n"
    DB "feet wet.\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "No need to\n"
    DB "swim. Just jump\n"
    DB "over instead!\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "I don't think\n"
    DB "Mel and I can't\n"
    DB "jump that far.\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Oh. Well I can!\n"
    DB "You two can use\n"
    DB "the bridges.\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Sewer0Dialog", ROMX

DataX_Sewer0Intro_dlog::
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "These giant\n"
    DB "pipes look\n"
    DB "really heavy.\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Ha! I bet I can\n"
    DB "push them. I'm\n"
    DB "VERY strong.\r"
    DB DIALOG_MOUSE
    DB "Good, because\n"
    DB "I'm kinda stuck\n"
    DB "in here...\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "City0Dialog", ROMX

DataX_City0Intro_dlog::
    DB DIALOG_MOUSE
    DB "Ugh, the city.\n"
    DB "This place is\n"
    DB "scary.\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "What's so scary\n"
    DB "about the city?\r"
    DB DIALOG_MOUSE
    DB "Mousetraps! If\n"
    DB "I run into one,\n"
    DB "I'm toast.\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Don't worry!\n"
    DB "We can help you\n"
    DB "avoid them.\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Remember, we\n"
    DB "can reset with\n"
    DB "the START menu.\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Space0Dialog", ROMX

DataX_Space0Intro_dlog::
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Well, Mel, you\n"
    DB "finally made it\n"
    DB "into space!\r"
    DB DIALOG_MOUSE
    DB "But we haven't\n"
    DB "reached the\n"
    DB "moon yet.\r"
    DB DIALOG_MOUSE
    DB "This station is\n"
    DB "only in low\n"
    DB "Earth orbit.\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Maybe a bigger\n"
    DB "spaceship can\n"
    DB "take us there?\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "I saw one at\n"
    DB "the other end\n"
    DB "of the station!\r"
    DB DIALOG_MOUSE
    DB "Sounds like we\n"
    DB "have a plan,\n"
    DB "then.\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Space5Dialog", ROMX

DataX_Space5Intro_dlog::
    DB DIALOG_MOUSE
    DB "At last, we've\n"
    DB "reached the\n"
    DB "final puzzle.\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "And it uses\n"
    DB "every mechanic\n"
    DB "in the game!\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "We can do it,\n"
    DB "gals! Best of\n"
    DB "luck to us!\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "CreditsDialog", ROMX

DataX_CreditsFlying_dlog::
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "Wheeeeeeeeeee!\n"
    DB "Here we go!\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "You know, Mel,\n"
    DB "you never did\n"
    DB "tell us...\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Why are you\n"
    DB "trying to get\n"
    DB "to the moon?\r"
    DB DIALOG_MOUSE
    DB "Oh, sorry. I\n"
    DB "thought it was\n"
    DB "obvious.\r"
    DB DIALOG_END

DataX_CreditsMoon_dlog::
    DB DIALOG_MOUSE
    DB "Everyone knows\n"
    DB "the moon is\n"
    DB "made of cheese!\r"
    DB DIALOG_BLANK
    DB "\n* BIG2SMALL *\r"
    DB DIALOG_BLANK
    DB " a game by\n"
    DB " Matthew D.\n"
    DB "   Steele\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB " * STARRING *\n"
    DB "   Elle the\n"
    DB "   Elephant\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB " * STARRING *\n"
    DB "  Gisele the\n"
    DB "     Goat\r"
    DB DIALOG_MOUSE
    DB " * STARRING *\n"
    DB "   Mel the\n"
    DB "    Mouse\r"
    DB DIALOG_BLANK
    DB "\n Thanks for\n"
    DB "  playing!\r"
    DB DIALOG_BLANK
    DB "\n  THE END\r"
    DB DIALOG_END

;;;=========================================================================;;;
