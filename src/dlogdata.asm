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
DataX_Space1Intro_dlog::
DataX_Space3Intro_dlog::
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

SECTION "Farm1Dialog", ROMX

DataX_Farm1Intro_dlog::
    DB DIALOG_MOUSE
    DB "Do you think\n"
    DB "these cows want\n"
    DB "to join us?\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Why don't we\n"
    DB "ask them?\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "Hey cows, want\n"
    DB "to come find\n"
    DB "food with us?\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Don't be silly,\n"
    DB "Gisele, animals\n"
    DB "can't talk!\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Farm2Dialog", ROMX

DataX_Farm2Intro_dlog::
    DB DIALOG_MOUSE
    DB "You know, these\n"
    DB "shrubs can be\n"
    DB "useful, Gisele.\r"
    DB DIALOG_MOUSE
    DB "And once you\n"
    DB "eat one, you\n"
    DB "can't uneat it.\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "True, but the\n"
    DB "puzzle always\n"
    DB "stays solvable.\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "So, we COULD\n"
    DB "reset with the\n"
    DB "START menu...\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "...but we never\n"
    DB "HAVE to!\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Farm4Dialog", ROMX

DataX_Farm4Intro_dlog::
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "I just noticed\n"
    DB "something back\n"
    DB "on the map...\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Why does this\n"
    DB "puzzle's marker\n"
    DB "look different?\r"
    DB DIALOG_MOUSE
    DB "It means we can\n"
    DB "unlock a bonus\n"
    DB "puzzle here.\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Oh, right! And\n"
    DB "we need a Par\n"
    DB "score for that.\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Yep! Check the\n"
    DB "START menu to\n"
    DB "see our score.\r"
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

SECTION "Mountain1Dialog", ROMX

DataX_Mountain1Intro_dlog::
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Huff...puff...\n"
    DB "This trail is\n"
    DB "no joke!\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Really? Because\n"
    DB "I think this\n"
    DB "trail is...\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "...HILL-arious!\r"
    DB DIALOG_MOUSE
    DB "Oh, boy. This\n"
    DB "is going to be\n"
    DB "a long trip.\r"
    DB DIALOG_END

DataX_Mountain1Outro_dlog::
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Just wondering,\n"
    DB "if we replay a\n"
    DB "puzzle again...\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "...how can we\n"
    DB "also replay our\n"
    DB "conversation?\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Easy, just hold\n"
    DB "SELECT while we\n"
    DB "enter a puzzle.\r"
    DB DIALOG_MOUSE
    DB "Right. So be\n"
    DB "sure to never\n"
    DB "do that.\r"
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

SECTION "Mountain5Dialog", ROMX

DataX_Mountain5Intro_dlog::
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Whew! We're\n"
    DB "almost through\n"
    DB "the mountains.\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "Yep, it's all\n"
    DB "downhill from\n"
    DB "here!\r"
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

SECTION "Lake1Dialog", ROMX

DataX_Lake1Intro_dlog::
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Hey Elle, how\n"
    DB "does the ocean\n"
    DB "say hello?\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "I don't know,\n"
    DB "how?\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "It WAVES!\r"
    DB DIALOG_MOUSE
    DB "...That joke\n"
    DB "was terrible.\r"
    DB DIALOG_END

DataX_Lake1Outro_dlog::
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Hey Elle, how\n"
    DB "does a sailor\n"
    DB "say goodbye?\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "I don't know,\n"
    DB "how?\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "SEA you later!\r"
    DB DIALOG_MOUSE
    DB "Please stop.\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Lake3Dialog", ROMX

DataX_Lake3Intro_dlog::
    DB DIALOG_MOUSE
    DB "Sigh...another\n"
    DB "river.\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Ready for some\n"
    DB "more jumping,\n"
    DB "Gisele?\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "I was born\n"
    DB "ready!\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Lake4Dialog", ROMX

DataX_Lake4Intro_dlog::
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Hey Mel, why\n"
    DB "did the river\n"
    DB "cross the road?\r"
    DB DIALOG_MOUSE
    DB "Really? Another\n"
    DB "one of these?\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "To WET to the\n"
    DB "other side!\r"
    DB DIALOG_MOUSE
    DB "That doesn't\n"
    DB "even make any\n"
    DB "sense!\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Sewer0Dialog", ROMX

DataX_Sewer0Intro_dlog::
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Well, here we\n"
    DB "are down in the\n"
    DB "sewers!\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "These giant\n"
    DB "pipes look\n"
    DB "really heavy.\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Ha! I bet I can\n"
    DB "push them. I'm\n"
    DB "VERY strong.\r"
    DB DIALOG_MOUSE
    DB "Good, maybe you\n"
    DB "could come get\n"
    DB "me out of here?\r"
    DB DIALOG_END

DataX_Sewer0Outro_dlog::
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Good thing\n"
    DB "there's lots of\n"
    DB "food down here!\r"
    DB DIALOG_MOUSE
    DB "...Should we be\n"
    DB "eating food out\n"
    DB "of the sewer?\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "It's probably\n"
    DB "fine.\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Sewer1Dialog", ROMX

DataX_Sewer1Intro_dlog::
    DB DIALOG_MOUSE
    DB "Ugh, I feel\n"
    DB "gross walking\n"
    DB "around in here.\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Maybe we need\n"
    DB "some kind of\n"
    DB "sewer shoes?\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "Maybe we should\n"
    DB "wear CLOGS!\r"
    DB DIALOG_MOUSE
    DB "I'll pretend I\n"
    DB "didn't hear\n"
    DB "that.\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Sewer2Dialog", ROMX

DataX_Sewer2Intro_dlog::
    DB DIALOG_MOUSE
    DB "This plumbing\n"
    DB "seems overly\n"
    DB "complicated.\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "Yeah, what are\n"
    DB "all these pipes\n"
    DB "even for?\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "It's as if this\n"
    DB "sewer is from a\n"
    DB "video game!\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Sewer3Dialog", ROMX

DataX_Sewer3Intro_dlog::
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Remember when\n"
    DB "we all met back\n"
    DB "in the forest?\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "We've come a\n"
    DB "long way since\n"
    DB "then!\r"
    DB DIALOG_MOUSE
    DB "And the puzzles\n"
    DB "have gotten a\n"
    DB "lot harder.\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Yep, but we're\n"
    DB "not beaten yet!\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "Sewer5Dialog", ROMX

DataX_Sewer5Intro_dlog::
    DB DIALOG_MOUSE
    DB "Finally, we're\n"
    DB "almost out of\n"
    DB "the sewers.\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Maybe the game\n"
    DB "will get easier\n"
    DB "from here on!\r"
    DB DIALOG_MOUSE
    DB "Somehow, I\n"
    DB "doubt it.\r"
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
    DB "And then we DO\n"
    DB "have to reset\n"
    DB "the puzzle.\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "Don't worry!\n"
    DB "We can help you\n"
    DB "avoid them.\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Remember, we\n"
    DB "can reset with\n"
    DB "the START menu.\r"
    DB DIALOG_END

DataX_City0Outro_dlog::
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "There, that\n"
    DB "wasn't so bad,\n"
    DB "was it?\r"
    DB DIALOG_MOUSE
    DB "That was\n"
    DB "terrifying.\r"
    DB DIALOG_MOUSE
    DB "Let's never do\n"
    DB "that puzzle\n"
    DB "ever again.\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "City1Dialog", ROMX

DataX_City1Intro_dlog::
    DB DIALOG_MOUSE
    DB "Yikes, how am I\n"
    DB "supposed to get\n"
    DB "through THIS?\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "We can reset if\n"
    DB "you actually\n"
    DB "hit a trap...\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "But a puzzle is\n"
    DB "always solvable\n"
    DB "until you do.\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "We can help you\n"
    DB "out if you seem\n"
    DB "stuck, Mel!\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "City2Dialog", ROMX

DataX_City2Intro_dlog::
    DB DIALOG_MOUSE
    DB "We're almost to\n"
    DB "the end of our\n"
    DB "journey.\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "But we're far\n"
    DB "from 100% on\n"
    DB "the title menu!\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "For 100%, we\n"
    DB "need *stars* on\n"
    DB "every puzzle.\r"
    DB DIALOG_MOUSE
    DB "Including every\n"
    DB "bonus puzzle.\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Wow! I wonder\n"
    DB "if it's worth\n"
    DB "the effort?\r"
    DB DIALOG_MOUSE
    DB "Probably not,\n"
    DB "honestly.\r"
    DB DIALOG_END

;;;=========================================================================;;;

SECTION "City4Dialog", ROMX

DataX_City4Intro_dlog::
    DB DIALOG_MOUSE
    DB "Finally. This\n"
    DB "is what I was\n"
    DB "looking for.\r"
    DB DIALOG_GOAT_MOUTH_CLOSED
    DB "A spaceship!\n"
    DB "All aboard,\n"
    DB "then?\r"
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Let's grab some\n"
    DB "snacks for the\n"
    DB "road first!\r"
    DB DIALOG_END

DataX_City4Outro_dlog::
    DB DIALOG_MOUSE
    DB "Okay everyone,\n"
    DB "it's time to\n"
    DB "lift off.\r"
    DB DIALOG_ELEPHANT_EYES_OPEN
    DB "This is going\n"
    DB "to be fun!\r"
    DB DIALOG_GOAT_MOUTH_OPEN
    DB "I'd say it's\n"
    DB "going to be a\n"
    DB "...BLAST!\r"
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

DataX_Space5Outro_dlog::
    DB DIALOG_ELEPHANT_EYES_CLOSED
    DB "Hooray, we did\n"
    DB "it!\r"
    DB DIALOG_MOUSE
    DB "Next stop, the\n"
    DB "moon!\r"
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
    DB "assumed it was\n"
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
