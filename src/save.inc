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

;;; The number of puzzles in the game:
NUM_PUZZLES     EQU 13
ASSERT NUM_PUZZLES <= 99
NUM_PUZZLES_BCD EQU (((NUM_PUZZLES / 10) << 4) | (NUM_PUZZLES % 10))

;;; The number of save files:
NUM_SAVE_FILES EQU 3

;;; Magic number that indicates that a save file is not empty.
MAGIC_FILE_EXISTS EQU $b2

;;; Bit indices for FILE_PuzzleStatus_u8_arr:
STATB_UNLOCKED EQU 0
STATB_SOLVED   EQU 1

;;; Flags indices for FILE_PuzzleStatus_u8_arr:
STATF_UNLOCKED EQU (1 << STATB_UNLOCKED)
STATF_SOLVED   EQU (1 << STATB_SOLVED)

;;;=========================================================================;;;

;;; FILE: Describes a progress file, either for a save file (in SRAM), or for
;;;   the current game (in WRAM).
RSRESET
;;; PuzzleStatus: Status flags for each puzzle.  Each entry in this array uses
;;;   the STATB_* constants.
FILE_PuzzleStatus_u8_arr    RB NUM_PUZZLES
;;; CurrentPuzzleNumber: The index number of the puzzle that's currently
;;;   selected on the world map.
FILE_CurrentPuzzleNumber_u8 RB 1
;;; NumSolvedPuzzles: The number of solved puzzles, encoded in BCD.
ASSERT NUM_PUZZLES <= 99
FILE_NumSolvedPuzzles_bcd8  RB 1
;;; Magic: If equal to MAGIC_FILE_EXISTS, then this save file exists.  If equal
;;;   to any other value, this save file is considered empty.
FILE_Magic_u8               RB 1
sizeof_FILE                 RB 0

;;;=========================================================================;;;

;;; SAVE: Summarizes a save file.
RSRESET
;;; NumSolvedPuzzles: The number of solved puzzles, encoded in BCD.
ASSERT NUM_PUZZLES <= 99
SAVE_NumSolvedPuzzles_bcd8  RB 1
;;; Exists: 1 if this save file exists, or 0 if it's empty.
SAVE_Exists_bool RB 1
sizeof_SAVE RB 0

;;;=========================================================================;;;
