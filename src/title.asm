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
INCLUDE "src/color.inc"
INCLUDE "src/hardware.inc"
INCLUDE "src/interrupt.inc"
INCLUDE "src/macros.inc"
INCLUDE "src/save.inc"
INCLUDE "src/tileset.inc"
INCLUDE "src/vram.inc"

;;;=========================================================================;;;

;;; The BG palette number to use for the title background.
TITLE_BG_PALETTE EQU 0

INTRO_LINES_SEP_ROW EQU 22
INTRO_LINES_COL EQU 6
INTRO_LINES_SCY EQU (TILE_HEIGHT * INTRO_LINES_SEP_ROW - SCRN_Y / 2)

TITLE_SEP_ROW EQU 6
TITLE_SCROLL_OFFSET EQU (SCRN_Y / 2 - TILE_HEIGHT * TITLE_SEP_ROW)

TITLE1_ROWS EQU 4
TITLE1_COLS EQU 18
TITLE1_START_ROW EQU (TITLE_SEP_ROW - TITLE1_ROWS)
TITLE1_START_COL EQU ((SCRN_X_B - TITLE1_COLS) / 2)

TITLE2_ROWS EQU 4
TITLE2_COLS EQU 12
TITLE2_START_ROW EQU TITLE_SEP_ROW
TITLE2_START_COL EQU ((SCRN_X_B - TITLE2_COLS) / 2)

TITLE_MENU_START_ROW EQU 0
TITLE_MENU_START_COL EQU 3

TITLE_MENU_ITEM_ERASE EQU NUM_SAVE_FILES
TITLE_MENU_NUM_ITEMS EQU (TITLE_MENU_ITEM_ERASE + 1)

URL_ROW EQU (TITLE_MENU_NUM_ITEMS + 1)

;;; The BG palette number to use for the title menu.
TITLE_MENU_PALETTE EQU 6

TITLE_WINDOW_ROWS EQU (URL_ROW + 1)
TITLE_WINDOW_HEIGHT EQU (TILE_HEIGHT * TITLE_WINDOW_ROWS)
TITLE_WINDOW_TOP EQU (SCRN_Y - TITLE_WINDOW_HEIGHT)

URL_START_TILEID EQU $80
TITLE1_START_TILEID EQU $90

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
    ;; Load colorset.
    ld c, COLORSET_SUMMER  ; param: colorset
    xcall FuncX_Colorset_Load
    ;; Initialize state.
    xor a
    ld [Ram_TitleMenuItem_u8], a
    ld [Ram_TitleMenuIsErasing_bool], a
_TitleScreen_ClearBgMap:
    ld c, " "  ; param: tile value
    call Func_TitleClearBgMap
    if_cgb call, Func_TitleClearBgColor
_TitleScreen_DrawUpperTitle:
    ld hl, Vram_BgMap + SCRN_VX_B * TITLE1_START_ROW + TITLE1_START_COL
    ld de, SCRN_VX_B - TITLE1_COLS
    ld a, TITLE1_START_TILEID
    ld b, TITLE1_ROWS
    .rowLoop
    ld c, TITLE1_COLS
    .colLoop
    ld [hl+], a
    add 4
    dec c
    jr nz, .colLoop
    add hl, de
    sub TITLE1_COLS * TITLE1_ROWS - 1
    dec b
    jr nz, .rowLoop
_TitleScreen_DrawLowerTitle:
    ld hl, Vram_BgMap + SCRN_VX_B * TITLE2_START_ROW + TITLE2_START_COL
    xld de, DataX_Title2TileMap_start
    ld b, TITLE2_ROWS
    .rowLoop
    ld c, TITLE2_COLS
    .colLoop
    ld a, [de]
    inc de
    ld [hl+], a
    dec c
    jr nz, .colLoop
    ld a, b
    ld bc, SCRN_VX_B - TITLE2_COLS
    add hl, bc
    ld b, a
    dec b
    jr nz, .rowLoop
_TitleScreen_DrawIntroLines:
    ld hl, Vram_BgMap + SCRN_VX_B * (INTRO_LINES_SEP_ROW - 1) + INTRO_LINES_COL
    COPY_FROM_ROM0 Data_IntroLine1_start, Data_IntroLine1_end
    ld hl, Vram_BgMap + SCRN_VX_B * INTRO_LINES_SEP_ROW + INTRO_LINES_COL
    COPY_FROM_ROM0 Data_IntroLine2_start, Data_IntroLine2_end
_TitleScreen_SetUpWindow:
    ;; Clear relevent portion of window.
    ld hl, Vram_WindowMap
    xor a
    ASSERT SCRN_VX_B * TITLE_WINDOW_ROWS < $100
    ld c, SCRN_VX_B * TITLE_WINDOW_ROWS
    .clearLoop
    ld [hl+], a
    dec c
    jr nz, .clearLoop
    if_cgb call, Func_TitleMenuColor
    ;; Draw URL.
    ld c, 16
    ld a, URL_START_TILEID
    ld hl, Vram_WindowMap + SCRN_VX_B * URL_ROW + 2
    .urlLoop
    ld [hl+], a
    inc a
    dec c
    jr nz, .urlLoop
    ;; Set up menu.
FILE_NUMBER = 0
    REPT NUM_SAVE_FILES
    ld b, FILE_NUMBER
    call Func_TitleMenuDrawFileItem
FILE_NUMBER = FILE_NUMBER + 1
    ENDR
    ld hl, (Vram_WindowMap \
            + SCRN_VX_B * (TITLE_MENU_START_ROW + TITLE_MENU_ITEM_ERASE) \
            + TITLE_MENU_START_COL)  ; dest
    COPY_FROM_ROM0 Data_StartEraseStr_start, Data_StartEraseStr_end
    ld c, ">"  ; cursor tile ID
    call Func_TitleMenuSetCursorTile
_TitleScreen_FadeIn:
    ;; Set up the STAT interrupt table.
    ld a, LCDCF_ON | LCDCF_BGON
    ldh [Hram_StatTable_hlcd_arr8 + 0 * sizeof_HLCD + HLCD_Lcdc_u8], a
    ldh [Hram_StatTable_hlcd_arr8 + 1 * sizeof_HLCD + HLCD_Lcdc_u8], a
    xor a
    ldh [Hram_StatTable_hlcd_arr8 + 0 * sizeof_HLCD + HLCD_Scy_u8], a
    ldh [Hram_StatTable_hlcd_arr8 + 1 * sizeof_HLCD + HLCD_Scy_u8], a
    ldh [Hram_StatTable_hlcd_arr8 + 0 * sizeof_HLCD + HLCD_NextLyc_u8], a
    ld a, 255
    ldh [Hram_StatTable_hlcd_arr8 + 1 * sizeof_HLCD + HLCD_NextLyc_u8], a
    ;; Fade in, then start playing the music.
    call Func_ClearOam
    call Func_MusicStop
    xor a
    ldh [rSCX], a
    ld a, INTRO_LINES_SCY
    ldh [rSCY], a
    ld d, LCDCF_BGON  ; param: display flags
    call Func_FadeIn
    PLAY_SONG DataX_Title_song
_TitleScreen_Intro:
    call Func_TitleIntro
    xor a
    ldh [rSCY], a
    ld a, 7
    ldh [rWX], a
    ld a, TITLE_WINDOW_TOP
    ldh [rWY], a
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_WINON | LCDCF_WIN9C00
    ldh [rLCDC], a
_TitleScreen_RunLoop:
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_UpdateButtonState
    ldh a, [Hram_ButtonsPressed_u8]
    ld b, a
_TitleScreen_HandleButtons:
    and PADF_START | PADF_A
    jr nz, _TitleScreen_OnConfirm
    bit PADB_UP, b
    jr nz, _TitleScreen_OnButtonUp
    bit PADB_DOWN, b
    jr nz, _TitleScreen_OnButtonDown
    jr _TitleScreen_RunLoop

_TitleScreen_OnButtonUp:
    ld c, " "  ; cursor tile ID
    call Func_TitleMenuSetCursorTile
    ld a, [Ram_TitleMenuItem_u8]
    sub 1
    jr nc, .noUnderflow
    ld a, TITLE_MENU_NUM_ITEMS - 1
    .noUnderflow
    jr _TitleScreen_UpdateCursor

_TitleScreen_OnButtonDown:
    ld c, " "  ; cursor tile ID
    call Func_TitleMenuSetCursorTile
    ld a, [Ram_TitleMenuItem_u8]
    inc a
    if_lt TITLE_MENU_NUM_ITEMS, jr, .noOverflow
    xor a
    .noOverflow
    jr _TitleScreen_UpdateCursor

_TitleScreen_OnConfirm:
    ld a, [Ram_TitleMenuItem_u8]
    if_ne TITLE_MENU_ITEM_ERASE, jr, _TitleScreen_SelectFile
    ld a, [Ram_TitleMenuIsErasing_bool]
    bit 0, a
    jp nz, _TitleScreen_StopErasing
    jr _TitleScreen_StartErasing

_TitleScreen_UpdateCursor:
    ld [Ram_TitleMenuItem_u8], a
    ld c, ">"  ; param: cursor tile ID
    call Func_TitleMenuSetCursorTile
    PLAY_SFX1 DataX_MenuMove_sfx1
    jr _TitleScreen_RunLoop

_TitleScreen_SelectFile:
    ld b, a
    ld a, [Ram_TitleMenuIsErasing_bool]
    bit 0, a
    jr nz, _TitleScreen_EraseFile
_TitleScreen_LoadFile:
    PLAY_SFX1 DataX_MenuConfirm_sfx1
    call Func_FadeOut
    ld a, [Ram_TitleMenuItem_u8]
    ld b, a  ; param: save file number
    call Func_LoadFile
    ;; If the first puzzle is still locked, this was an empty file, so we
    ;; should start on the world map.
    ld hl, Ram_Progress_file + FILE_PuzzleStatus_u8_arr + 0
    bit STATB_UNLOCKED, [hl]
    jp z, Main_WorldMapNewGame
    ;; Otherwise, start on the current area map.
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
    ld hl, (Vram_WindowMap + SCRN_VX_B * TITLE_MENU_START_ROW \
            + TITLE_MENU_START_COL + 9)
    add hl, bc  ; dest
    COPY_FROM_ROM0 Data_FileEmptyStr_start, Data_FileEmptyStr_end
    ;; Actually erase the file.
    ld a, [Ram_TitleMenuItem_u8]
    ld b, a  ; param: save file number
    call Func_EraseFile
    PLAY_SFX4 DataX_Mousetrap_sfx4
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
    ld hl, (Vram_WindowMap \
            + SCRN_VX_B * (TITLE_MENU_START_ROW + TITLE_MENU_ITEM_ERASE) \
            + TITLE_MENU_START_COL)  ; dest
    COPY_FROM_ROM0 Data_StopEraseStr_start, Data_StopEraseStr_end
    ;; Enable erase mode.
    ld a, 1
    ld [Ram_TitleMenuIsErasing_bool], a
    PLAY_SFX1 DataX_MenuConfirm_sfx1
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
    ld hl, (Vram_WindowMap \
            + SCRN_VX_B * (TITLE_MENU_START_ROW + TITLE_MENU_ITEM_ERASE) \
            + TITLE_MENU_START_COL)  ; dest
    COPY_FROM_ROM0 Data_StartEraseStr_start, Data_StartEraseStr_end
    ;; Disable erase mode.
    xor a
    ld [Ram_TitleMenuIsErasing_bool], a
    PLAY_SFX1 DataX_MenuConfirm_sfx1
    jp _TitleScreen_RunLoop

;;;=========================================================================;;;

SECTION "TitleIntro", ROM0

Func_TitleIntro:
    ld c, 88
    .loop
    push bc
    call Func_UpdateAudio
    call Func_WaitForVBlank
    call Func_UpdateButtonState
    pop bc
    ldh a, [Hram_ButtonsPressed_u8]
    and PADF_START | PADF_A | PADF_B
    ret nz
    dec c
    jr nz, .loop
_TitleIntro_IntroSlam:
    call Func_EnableLycInterrupt
    ld c, SCRN_Y / 2
    .loop
    ld a, LOW(Hram_StatTable_hlcd_arr8)
    ldh [Hram_StatNext_hlcd_hptr], a
    ;; rSCY = -TITLE_SCROLL_OFFSET + c
    ld a, -TITLE_SCROLL_OFFSET
    add c
    ldh [rSCY], a
    ;; rLYC = SCRN_Y / 2 - c
    ld a, SCRN_Y / 2
    sub c
    ldh [rLYC], a
    ;; hlcd[0].Scy = INTRO_LINES_SCY
    ld a, INTRO_LINES_SCY
    ldh [Hram_StatTable_hlcd_arr8 + 0 * sizeof_HLCD + HLCD_Scy_u8], a
    ;; hlcd[0].NextLyc = SCRN_Y / 2 + c
    ld a, SCRN_Y / 2
    add c
    ldh [Hram_StatTable_hlcd_arr8 + 0 * sizeof_HLCD + HLCD_NextLyc_u8], a
    ;; hlcd[1].Scy = -TITLE_SCROLL_OFFSET - c
    ld a, -TITLE_SCROLL_OFFSET
    sub c
    ldh [Hram_StatTable_hlcd_arr8 + 1 * sizeof_HLCD + HLCD_Scy_u8], a
    ;; Process frame.
    push bc
    call Func_UpdateAudio
    call Func_WaitForVBlank
    call Func_UpdateButtonState
    pop bc
    ldh a, [Hram_ButtonsPressed_u8]
    and PADF_START | PADF_A | PADF_B
    ret nz
    ASSERT (SCRN_Y / 2) % 3 == 0
    dec c
    dec c
    dec c
    jr nz, .loop
    ;; Disable LY=LYC interrupt.
    ld a, IEF_VBLANK
    ldh [rIE], a
_TitleIntro_IntroShake:
    PLAY_SFX4 DataX_TitleCrash_sfx4
    ld c, 31
    .loop
    push bc
    call Func_UpdateAudio
    call Func_WaitForVBlank
    call Func_UpdateButtonState
    pop bc
    ldh a, [Hram_ButtonsPressed_u8]
    and PADF_START | PADF_A | PADF_B
    ret nz
    ld a, -TITLE_SCROLL_OFFSET - 1
    bit 1, c
    jr z, .shake
    bit 4, c
    jr z, .small
    inc a
    .small
    inc a
    .shake
    ldh [rSCY], a
    dec c
    jr nz, .loop
_TitleIntro_IntroWait:
    ld a, -TITLE_SCROLL_OFFSET
    ldh [rSCY], a
    ld c, 60
    .loop
    push bc
    call Func_UpdateAudio
    call Func_WaitForVBlank
    call Func_UpdateButtonState
    pop bc
    ldh a, [Hram_ButtonsPressed_u8]
    and PADF_START | PADF_A | PADF_B
    ret nz
    dec c
    jr nz, .loop
_TitleIntro_IntroScroll:
    ;; Enable window.
    ld a, 7
    ldh [rWX], a
    ld a, SCRN_Y - 2
    ldh [rWY], a
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_WINON | LCDCF_WIN9C00
    ldh [rLCDC], a
    ;; Loop, scrolling title and scrolling window into view.
    ld c, TITLE_SCROLL_OFFSET - 1
    .loop
    push bc
    call Func_UpdateAudio
    call Func_WaitForVBlank
    call Func_UpdateButtonState
    pop bc
    ldh a, [Hram_ButtonsPressed_u8]
    and PADF_START | PADF_A | PADF_B
    ret nz
    ;; Scroll background:
    xor a
    sub c
    ldh [rSCY], a
    ;; Scroll menu window:
    ld a, TITLE_WINDOW_TOP
    ASSERT TITLE_WINDOW_HEIGHT == 2 * TITLE_SCROLL_OFFSET
    add c
    add c
    ldh [rWY], a
    dec c
    jr nz, .loop
    ret

;;;=========================================================================;;;

SECTION "TitleDrawFunctions", ROM0

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
    ld hl, (Vram_WindowMap + SCRN_VX_B * TITLE_MENU_START_ROW \
            + TITLE_MENU_START_COL)
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

;;; Sets the whole title menu to use TITLE_MENU_PALETTE.
;;; @prereq Color is enabled.
;;; @prereq LCD is off.
Func_TitleMenuColor:
    ;; Switch to VRAM bank 1.
    ld a, 1
    ldh [rVBK], a
    ;; Set the relevant portion of the window to TITLE_MENU_PALETTE.
    ld hl, Vram_WindowMap
    ld a, TITLE_MENU_PALETTE
    ld c, TITLE_WINDOW_ROWS * SCRN_VX_B
    .loop
    ld [hl+], a
    dec c
    jr nz, .loop
    ;; Switch back to VRAM bank 0.
    xor a
    ldh [rVBK], a
    ret

;;; Sets all tiles in the BG map to use TITLE_BG_PALETTE.
;;; @prereq Color is enabled.
;;; @prereq LCD is off.
Func_TitleClearBgColor:
    ;; Switch to VRAM bank 1.
    ld a, 1
    ldh [rVBK], a
    ;; Fill the BG map with TITLE_BG_PALETTE.
    ld c, TITLE_BG_PALETTE  ; param: tile value
    call Func_TitleClearBgMap
    ;; Switch back to VRAM bank 0.
    xor a
    ldh [rVBK], a
    ret

;;; Fills all tiles in the BG map with the given value.
;;; @prereq LCD is off.
;;; @param c The value to set on each tile.
Func_TitleClearBgMap:
    ld a, c
    ld hl, Vram_BgMap
    ld c, 0
    .loop
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    dec c
    jr nz, .loop
    ret

;;;=========================================================================;;;

SECTION "TitleMenuStrings", ROM0

Data_IntroLine1_start:
    DB "mdsteele"
Data_IntroLine1_end:

Data_IntroLine2_start:
    DB "PRESENTS"
Data_IntroLine2_end:

Data_StartEraseStr_start:
Data_EraseItemStr_start:
    DB "Erase "
Data_EraseItemStr_end:
    DB "file"
Data_StartEraseStr_end:

Data_FileItemStr_start:
    DB "File "
Data_FileItemStr_end:

Data_StopEraseStr_start:
    DB "Done      "
Data_StopEraseStr_end:

Data_FileEmptyStr_start:
    DB "Empty"
Data_FileEmptyStr_end:

;;;=========================================================================;;;
