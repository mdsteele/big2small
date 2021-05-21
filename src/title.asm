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
INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"
INCLUDE "src/save.inc"
INCLUDE "src/tileset.inc"

;;;=========================================================================;;;

TITLE_MENU_ROW EQU (SCRN_Y_B - NUM_SAVE_FILES - 3)
TITLE_MENU_COL EQU 3

TITLE_MENU_ITEM_ERASE EQU NUM_SAVE_FILES
TITLE_MENU_NUM_ITEMS EQU (TITLE_MENU_ITEM_ERASE + 1)

URL_ROW EQU (SCRN_Y_B - 1)

;;;=========================================================================;;;

SECTION "TitleState", WRAM0

;;; Which item of the title menu the cursor is on.
Ram_TitleMenuItem_u8:
    DB

;;; Whether we're in file erase mode.
Ram_TitleMenuIsErasing_bool:
    DB

;;;=========================================================================;;;

SECTION "TitleFunctions", ROM0

;;; @prereq LCD is off.
Main_TitleScreen::
    ;; Load tileset.
    ld b, TILESET_TITLE  ; param: tileset
    call Func_LoadTileset
    ;; Initialize state.
    xor a
    ld [Ram_TitleMenuItem_u8], a
    ld [Ram_TitleMenuIsErasing_bool], a
    ldh [rSCX], a
    ldh [rSCY], a
    ;; Clear relevant part of background map.
    ld a, " "
    ld hl, Vram_BgMap
    ld c, 141
    .clearLoop
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    dec c
    jr nz, .clearLoop
    ;; Draw URL.
    ld a, $f0
    ld hl, Vram_BgMap + SCRN_VX_B * URL_ROW + 2
    .urlLoop
    ld [hl+], a
    inc a
    jr nz, .urlLoop
    ;; Set up menu.
FILE_NUMBER = 0
    REPT NUM_SAVE_FILES
    ld b, FILE_NUMBER
    call Func_TitleMenuDrawFileItem
FILE_NUMBER = FILE_NUMBER + 1
    ENDR
    ld hl, (Vram_BgMap + SCRN_VX_B * (TITLE_MENU_ROW + TITLE_MENU_ITEM_ERASE) \
            + TITLE_MENU_COL)  ; dest
    COPY_FROM_ROM0 Data_StartEraseStr_start, Data_StartEraseStr_end
    ld c, ">"  ; cursor tile ID
    call Func_TitleMenuSetCursorTile
    ;; Set up objects.
    call Func_ClearOam
    ;; Initialize music.
    ld c, BANK(DataX_TitleMusic_song)
    ld hl, DataX_TitleMusic_song
    call Func_MusicStart
    ;; Turn on the LCD and fade in.
    call Func_PerformDma
    call Func_FadeIn
_TitleScreen_RunLoop:
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_UpdateButtonState
    ld a, [Ram_ButtonsPressed_u8]
    ld b, a
_TitleScreen_HandleButtonUp:
    bit PADB_UP, b
    jr z, .noPress
    ld c, " "  ; cursor tile ID
    call Func_TitleMenuSetCursorTile
    ld a, [Ram_TitleMenuItem_u8]
    sub 1
    jr nc, .noUnderflow
    ld a, TITLE_MENU_NUM_ITEMS - 1
    .noUnderflow
    jr _TitleScreen_UpdateCursor
    .noPress
_TitleScreen_HandleButtonDown:
    bit PADB_DOWN, b
    jr z, .noPress
    ld c, " "  ; cursor tile ID
    call Func_TitleMenuSetCursorTile
    ld a, [Ram_TitleMenuItem_u8]
    inc a
    if_lt TITLE_MENU_NUM_ITEMS, jr, .noOverflow
    xor a
    .noOverflow
    jr _TitleScreen_UpdateCursor
    .noPress
_TitleScreen_HandleButtonStart:
    bit PADB_START, b
    jr z, _TitleScreen_RunLoop
    ld a, [Ram_TitleMenuItem_u8]
    if_ne TITLE_MENU_ITEM_ERASE, jr, _TitleScreen_SelectFile
    ld a, [Ram_TitleMenuIsErasing_bool]
    bit 0, a
    jr nz, _TitleScreen_StopErasing
    jr _TitleScreen_StartErasing

_TitleScreen_UpdateCursor:
    ld [Ram_TitleMenuItem_u8], a
    ld c, ">"  ; param: cursor tile ID
    call Func_TitleMenuSetCursorTile
    jr _TitleScreen_RunLoop

_TitleScreen_SelectFile:
    ld b, a
    ld a, [Ram_TitleMenuIsErasing_bool]
    bit 0, a
    jr nz, _TitleScreen_EraseFile
_TitleScreen_LoadFile:
    call Func_FadeOut
    ld a, [Ram_TitleMenuItem_u8]
    ld b, a  ; param: save file number
    call Func_LoadFile
    ;; TODO: Go to world map instead if file is empty.
    ld c, 0  ; param: puzzle status
    jp Main_AreaMapResume

_TitleScreen_EraseFile:
    ;; Change the menu text to indicate that the file is empty.
    ASSERT NUM_SAVE_FILES < 8
    ASSERT SCRN_VX_B == 32
    ld a, [Ram_TitleMenuItem_u8]
    swap a
    rlca
    ldb bc, a
    ld hl, Vram_BgMap + SCRN_VX_B * TITLE_MENU_ROW + TITLE_MENU_COL + 9
    add hl, bc  ; dest
    COPY_FROM_ROM0 Data_FileEmptyStr_start, Data_FileEmptyStr_end
    ;; Actually erase the file.
    ld a, [Ram_TitleMenuItem_u8]
    ld b, a  ; param: save file number
    call Func_EraseFile
    jp _TitleScreen_RunLoop

_TitleScreen_StartErasing:
    ;; Change each "FILE X" item to "ERASE X".
FILE_NUMBER = 0
    REPT NUM_SAVE_FILES
    ld b, FILE_NUMBER
    call Func_TitleMenuSetItemToErase
FILE_NUMBER = FILE_NUMBER + 1
    ENDR
    ;; Change the "ERASE FILE" item to "END".
    ld hl, (Vram_BgMap + SCRN_VX_B * (TITLE_MENU_ROW + TITLE_MENU_ITEM_ERASE) \
            + TITLE_MENU_COL)  ; dest
    COPY_FROM_ROM0 Data_StopEraseStr_start, Data_StopEraseStr_end
    ;; Enable erase mode.
    ld a, 1
    ld [Ram_TitleMenuIsErasing_bool], a
    jp _TitleScreen_RunLoop

_TitleScreen_StopErasing:
    ;; Change each "ERASE X" item back to "FILE X".
FILE_NUMBER = 0
    REPT NUM_SAVE_FILES
    ld b, FILE_NUMBER
    call Func_TitleMenuSetItemToFile
FILE_NUMBER = FILE_NUMBER + 1
    ENDR
    ;; Change the "END" item back to "ERASE FILE".
    ld hl, (Vram_BgMap + SCRN_VX_B * (TITLE_MENU_ROW + TITLE_MENU_ITEM_ERASE) \
            + TITLE_MENU_COL)  ; dest
    COPY_FROM_ROM0 Data_StartEraseStr_start, Data_StartEraseStr_end
    ;; Disable erase mode.
    xor a
    ld [Ram_TitleMenuIsErasing_bool], a
    jp _TitleScreen_RunLoop

;;;=========================================================================;;;

;;; @param b The menu item number.
;;; @return hl A pointer to the first BG map tile of the menu item.
;;; @preserve bc
Func_GetTitleMenuItemPtr_hl:
    ;; Store SCRN_VX_B * b in de.
    ASSERT TITLE_MENU_NUM_ITEMS < 8
    ASSERT SCRN_VX_B == 32
    ld a, b
    swap a
    rlca
    ldb de, a
    ;; Make hl point to the first BG map tile of the menu item.
    ld hl, Vram_BgMap + SCRN_VX_B * TITLE_MENU_ROW + TITLE_MENU_COL
    add hl, de
    ret

;;; Sets the tile ID in the BG map for the title menu cursor.
;;; @param c Tile ID to place (should be either " " or ">").
Func_TitleMenuSetCursorTile:
    ld a, [Ram_TitleMenuItem_u8]
    ld b, a
    call Func_GetTitleMenuItemPtr_hl  ; preserves c
    dec hl
    ld [hl], c
    ret

;;; @param b The save file number.
Func_TitleMenuSetItemToFile:
    push bc
    call Func_GetTitleMenuItemPtr_hl  ; dest
    COPY_FROM_ROM0 Data_FileItemStr_start, Data_FileItemStr_end
    pop bc
    ;; Draw the save file's letter.
    ld a, "A"
    add b
    ld [hl+], a
    ld a, "."
    ld [hl], a
    ret

;;; @param b The save file number.
Func_TitleMenuSetItemToErase:
    push bc
    call Func_GetTitleMenuItemPtr_hl  ; dest
    COPY_FROM_ROM0 Data_EraseItemStr_start, Data_EraseItemStr_end
    pop bc
    ;; Draw the save file's letter.
    ld a, "A"
    add b
    ld [hl], a
    ret

;;; @param b The save file number.
Func_TitleMenuDrawFileItem:
    ;; Draw the base save file menu item string.
    push bc
    call Func_GetTitleMenuItemPtr_hl  ; dest
    COPY_FROM_ROM0 Data_FileItemStr_start, Data_FileItemStr_end
    pop bc
    ;; Draw the save file's letter.
    ld a, "A"
    add b
    ld [hl+], a
    ld a, "."
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ;; Get the save file's status.
    push hl
    call Func_GetSaveSummaryPtr_hl
    ASSERT SAVE_Percentage_bcd8 == 0
    ld a, [hl+]
    ASSERT SAVE_Exists_bool == 1
    ld c, [hl]
    pop hl
    ;; If the file is empty, draw the word "Empty".
    bit 0, c
    jr nz, .notEmpty
    COPY_FROM_ROM0 Data_FileEmptyStr_start, Data_FileEmptyStr_end
    ret
    .notEmpty
    ;; If the file is at 100%, draw "*100%".
    if_ne HUNDRED_PERCENT_BCD8, jr, .not100Percent
    ld a, "*"
    ld [hl+], a
    ld a, "1"
    ld [hl+], a
    ld a, "0"
    ld [hl+], a
    ld [hl+], a
    jr .percent
    .not100Percent
    ;; Otherwise, draw "..XX%", where XX is the two-digit percentage.
    ld c, a
    ld a, "."
    ld [hl+], a
    ld [hl+], a
    ld a, c
    swap a
    and $0f
    add "0"
    ld [hl+], a
    ld a, c
    and $0f
    add "0"
    ld [hl+], a
    .percent
    ld [hl], "%"
    ret

;;;=========================================================================;;;

SECTION "TitleMenuStrings", ROM0

Data_StartEraseStr_start::
Data_EraseItemStr_start::
    DB "Erase "
Data_EraseItemStr_end::
    DB "file"
Data_StartEraseStr_end::

Data_FileItemStr_start::
    DB "File "
Data_FileItemStr_end::

Data_StopEraseStr_start::
    DB "Done      "
Data_StopEraseStr_end::

Data_FileEmptyStr_start::
    DB "Empty"
Data_FileEmptyStr_end::

;;;=========================================================================;;;
