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

INCLUDE "src/areamap.inc"
INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"
INCLUDE "src/save.inc"

;;;=========================================================================;;;

SECTION "Sram", SRAM[$A000], BANK[0]

Sram_Save0_file:
    DS sizeof_FILE
Sram_Save1_file:
    DS sizeof_FILE
Sram_Save2_file:
    DS sizeof_FILE
ASSERT NUM_SAVE_FILES == 3

;;;=========================================================================;;;

SECTION "Progress", WRAM0, ALIGN[8]

;;; The active game progress file.
Ram_Progress_file::
    DS sizeof_FILE

;;; Status flags for each area, calculated from Ram_Progress_file.  Each entry
;;; in this array uses the STATB_* constants, and is the bitwise AND of the
;;; statuses (from FILE_PuzzleStatus_u8_arr) of all puzzles in that area.
Ram_ProgressAreas_u8_arr::
    DS NUM_AREAS

;;;=========================================================================;;;

SECTION "SaveState", WRAM0

;;; The most recently loaded save file number.
Ram_SaveFileNumber_u8:
    DB

;;; An array of SAVE structs that summarize the state of the save files.
Ram_SaveSummaries_save_arr:
    DS sizeof_SAVE * NUM_SAVE_FILES

;;;=========================================================================;;;

SECTION "SaveFunctions", ROM0

;;; If the specified save file is not empty, loads it into Ram_Progress_file.
;;; Otherwise, starts a new game in Ram_Progress_file, and saves it to the
;;; specified save file.
;;; @param b The save file number to load from.
Func_LoadFile::
    ld a, b
    ld [Ram_SaveFileNumber_u8], a
    ;; If the save file is empty, start a new game.
    call Func_GetSaveSummaryPtr_hl  ; preserves b
    ASSERT SAVE_Exists_bool == 1
    inc hl
    bit 0, [hl]
    jr z, _LoadFile_NewGame
    ;; Otherwise, load the save file into Ram_Progress_file.
    call Func_GetSaveFilePtr_hl
    ldw de, hl  ; param: source
    ld hl, Ram_Progress_file  ; param: destintation
    call Func_SramFileTransfer
    ;; Finish by updating Ram_ProgressAreas_u8_arr.
    jp Func_UpdateProgressAreas

_LoadFile_NewGame:
    ;; Set the current puzzle to the first one.
    xor a
    ld [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8], a
    ;; Mark all puzzles as locked and unsolved.
    ld c, NUM_PUZZLES
    ld hl, Ram_Progress_file + FILE_PuzzleStatus_u8_arr
    .statusLoop
    ld [hl+], a
    dec c
    jr nz, .statusLoop
    ;; Mark all areas as unfinished.
    ld c, NUM_AREAS
    ld hl, Ram_ProgressAreas_u8_arr
    .areaLoop
    ld [hl+], a
    dec c
    jr nz, .areaLoop
    ;; Set all puzzle best scores to 999.
    ld c, NUM_PUZZLES
    ld hl, Ram_Progress_file + FILE_PuzzleBest_bcd16_arr
    ld a, $99
    .bestLoop
    ld [hl+], a
    ld [hl], $09
    inc hl
    dec c
    jr nz, .bestLoop
    ;; Mark the file as existent.
    ld a, MAGIC_FILE_EXISTS
    ld [Ram_Progress_file + FILE_Magic_u8], a
    ret

;;; Saves Ram_Progress_file to the current save file in SRAM.
Func_SaveFile::
    ;; Update the save summary.
    ld hl, Ram_Progress_file  ; param: FILE ptr
    call Func_GetFilePercentageBcd_c
    ld a, [Ram_SaveFileNumber_u8]
    ld b, a  ; param: save file number
    call Func_GetSaveSummaryPtr_hl  ; preserves bc
    ASSERT SAVE_Percentage_bcd8 == 0
    ld a, c
    ld [hl+], a
    ASSERT SAVE_Exists_bool == 1
    ld [hl], 1
    ;; Save the file to SRAM.
    call Func_GetSaveFilePtr_hl  ; param: dest
    ld de, Ram_Progress_file  ; param: source
    ;; fall through to Func_SramFileTransfer

;;; Copies a FILE struct to/from SRAM.
;;; @param hl Destination start address.
;;; @param de Source start address.
Func_SramFileTransfer:
    ld bc, sizeof_FILE
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a
    call Func_MemCopy
    ld a, CART_SRAM_DISABLE
    ld [rRAMG], a
    ret

;;; Erases the specified save file.
;;; @param b The save file number to erase.
Func_EraseFile::
    ;; Mark the save summary as erased.
    call Func_GetSaveSummaryPtr_hl  ; preserves b
    ASSERT SAVE_Exists_bool == 1
    inc hl
    ld [hl], 0
    ;; Mark the file in SRAM as erased.
    call Func_GetSaveFilePtr_hl
    ld de, FILE_Magic_u8
    add hl, de
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a
    ld [hl], 0
    ld a, CART_SRAM_DISABLE
    ld [rRAMG], a
    ret

;;;=========================================================================;;;

;;; @param hl A pointer to a FILE struct.
;;; @return c The progress percentage for the file (0-100), encoded in BCD for
;;;     0-99, or the special value HUNDRED_PERCENT_BCD8 for 100.
;;; @preserve b
Func_GetFilePercentageBcd_c:
    ;; Set a and d to zero.  These will store BCD numbers.
    xor a
    ld d, a
    ;; Loop over the FILE_PuzzleStatus_u8_arr for the FILE that hl points to.
    ld c, NUM_PUZZLES
    ASSERT FILE_PuzzleStatus_u8_arr == 0
    .loop
    ;; Increment a once if the puzzle is solved, twice if solved within par.
    bit STATB_SOLVED, [hl]
    jr z, .continue
    inc a
    bit STATB_MADE_PAR, [hl]
    jr z, .notWithinPar
    inc a
    .notWithinPar
    ;; If all puzzles were solved within par, that would add up to 80, but we
    ;; want it to add up to 100, so we need to multiply the count by 5/4.  To
    ;; do this, every time a reaches 4 or more, we increment it an additional
    ;; time, add it to d (in BCD), then reset a to zero.
    ASSERT 2 * NUM_PUZZLES == 80
    if_lt 4, jr, .continue
    inc a
    add d
    daa
    ;; If adding a to d causes an overflow, that means we hit 100%, so jump to
    ;; the special case below.
    jr c, .hundredPercent
    ld d, a
    xor a
    ;; Advance to the next entry in FILE_PuzzleStatus_u8_arr and continue the
    ;; loop.
    .continue
    inc hl
    dec c
    jr nz, .loop
    ;; When the loop completes, there may be some leftover percentage points in
    ;; a, so add those into d (in BCD), then put the final return value into c.
    add d
    daa
    ld c, a
    ret
    ;; Special case for 100%: since 100 doesn't fit in a one-byte BCD value, we
    ;; use a special return value to signify 100%.
    .hundredPercent
    ld c, HUNDRED_PERCENT_BCD8
    ret

;;;=========================================================================;;;

;;; Populates each summary SAVE struct from the corresponding SRAM FILE struct.
Func_InitSaveSummaries::
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a
    ld b, 0
    .loop
    call Func_InitSaveSummary  ; preserves b
    inc b
    ld a, b
    if_lt NUM_SAVE_FILES, jr, .loop
    ld a, CART_SRAM_DISABLE
    ld [rRAMG], a
    ret

;;; Populates the specified summary SAVE struct from the corresponding SRAM
;;; FILE struct.
;;; @param b The save file number.
;;; @preserve b
Func_InitSaveSummary:
    call Func_GetSaveFilePtr_hl  ; preserves b
    ASSERT FILE_Magic_u8 != 0
    ld de, FILE_Magic_u8
    add hl, de
    ld a, [hl]
    if_eq MAGIC_FILE_EXISTS, jr, _InitSaveSummary_NonEmpty
_InitSaveSummary_Empty:
    call Func_GetSaveSummaryPtr_hl  ; preserves b
    ASSERT SAVE_Exists_bool == 1
    inc hl
    ld [hl], 0
    ret
_InitSaveSummary_NonEmpty:
    call Func_GetSaveFilePtr_hl  ; preserves b
    call Func_GetFilePercentageBcd_c  ; preserves b
    call Func_GetSaveSummaryPtr_hl  ; preserves bc
    ASSERT SAVE_Percentage_bcd8 == 0
    ld a, c
    ld [hl+], a
    ASSERT SAVE_Exists_bool == 1
    ld [hl], 1
    ret

;;;=========================================================================;;;

;;; Returns a pointer to the specified save file in SRAM.
;;; @param b The save file number.
;;; @return hl A pointer to a FILE struct in SRAM.
;;; @preserve bc, de
Func_GetSaveFilePtr_hl:
    ld a, b
    ASSERT NUM_SAVE_FILES == 3
    if_eq 2, jr, .file2
    if_eq 1, jr, .file1
    .file0
    ld hl, Sram_Save0_file
    ret
    .file1
    ld hl, Sram_Save1_file
    ret
    .file2
    ld hl, Sram_Save2_file
    ret

;;; Returns a pointer to the specified save summary in WRAM.
;;; @param b The save file number.
;;; @return hl A pointer to a SAVE struct in WRAM.
;;; @preserve bc
Func_GetSaveSummaryPtr_hl::
    ld a, b
    ASSERT NUM_SAVE_FILES * sizeof_SAVE <= $ff
    ASSERT sizeof_SAVE == 2
    rlca
    ldb de, a
    ld hl, Ram_SaveSummaries_save_arr
    add hl, de
    ret

;;;=========================================================================;;;

UPDATE_AREA: MACRO
    STATIC_ASSERT _NARG == 2
    ld c, (\2)
    ld a, $ff
    .loop\@
    and [hl]
    inc hl
    dec c
    jr nz, .loop\@
    ld [Ram_ProgressAreas_u8_arr + (\1)], a
ENDM

;;; Regenerates Ram_ProgressAreas_u8_arr from Ram_Progress_file.
Func_UpdateProgressAreas::
    ld hl, Ram_Progress_file + FILE_PuzzleStatus_u8_arr
    UPDATE_AREA AREA_FOREST, NUM_FOREST_PUZZLES
    UPDATE_AREA AREA_FARM, NUM_FARM_PUZZLES
    UPDATE_AREA AREA_MOUNTAIN, NUM_MOUNTAIN_PUZZLES
    UPDATE_AREA AREA_LAKE, NUM_LAKE_PUZZLES
    UPDATE_AREA AREA_SEWER, NUM_SEWER_PUZZLES
    UPDATE_AREA AREA_CITY, NUM_CITY_PUZZLES
    UPDATE_AREA AREA_SPACE, NUM_SPACE_PUZZLES
    ret

;;;=========================================================================;;;
