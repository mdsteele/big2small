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
INCLUDE "src/interrupt.inc"
INCLUDE "src/macros.inc"
INCLUDE "src/puzzle.inc"
INCLUDE "src/save.inc"
INCLUDE "src/vram.inc"

;;;=========================================================================;;;

;;; The height, in pixels, of the pause window when fully visible.
PAUSE_WINDOW_HEIGHT EQU (5 * TILE_HEIGHT)

;;; The number of pixels per frame that the window slides up/down while
;;; pausing/unpausing.
PAUSE_WINDOW_SPEED EQU 4
STATIC_ASSERT PAUSE_WINDOW_HEIGHT % PAUSE_WINDOW_SPEED == 0

;;; The index of each menu item (as stored in Ram_PauseMenuItem_u8), as well as
;;; the total number of menu items.
PAUSE_MENU_ITEM_UNPAUSE EQU 0
PAUSE_MENU_ITEM_RESET   EQU 1
PAUSE_MENU_ITEM_QUIT    EQU 2
PAUSE_MENU_NUM_ITEMS    EQU 3

;;;=========================================================================;;;

SECTION "PauseState", WRAM0

;;; Which item of the pause menu the cursor is on (0-2).
Ram_PauseMenuItem_u8:
    DB

;;; The signed value to add to rWY each frame until the pause window is fully
;;; visible or fully hidden.
Ram_PauseWindowVelocity_i8:
    DB

;;; How many rows of the window tile map we've drawn so far.  (We don't draw
;;; them all at once to avoid running over the VBlank period.)
Ram_PauseWindowRowsDrawn_u8:
    DB

;;;=========================================================================;;;

SECTION "MainPause", ROM0

Main_BeginPause::
    ;; Start drawing window contents.
    xor a
    ld [Ram_PauseWindowRowsDrawn_u8], a
    xcall FuncX_DrawPause_DrawNextWindowRow
    ;; Show the window.
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | \
          LCDCF_WINON | LCDCF_WIN9C00
    ldh [rLCDC], a
    ld a, 7
    ldh [rWX], a
    ld a, SCRN_Y - PAUSE_WINDOW_SPEED
    ldh [rWY], a
    ldh [rLYC], a
    ;; Set up the STAT interrupt table.
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00
    ldh [Hram_StatTable_hlcd_arr8 + 0 * sizeof_HLCD + HLCD_Lcdc_u8], a
    xor a
    ldh [Hram_StatTable_hlcd_arr8 + 0 * sizeof_HLCD + HLCD_Scy_u8], a
    ld a, 255
    ldh [Hram_StatTable_hlcd_arr8 + 0 * sizeof_HLCD + HLCD_NextLyc_u8], a
    ld a, LOW(Hram_StatTable_hlcd_arr8)
    ldh [Hram_StatNext_hlcd_hptr], a
    call Func_EnableLycInterrupt
    ;; Hide arrow objects.
    xor a
    ld [Ram_ArrowN_oama + OAMA_Y], a
    ld [Ram_ArrowS_oama + OAMA_Y], a
    ld [Ram_ArrowE_oama + OAMA_Y], a
    ld [Ram_ArrowW_oama + OAMA_Y], a
    ;; Initialize state.
    xor a
    ld [Ram_PauseMenuItem_u8], a
    ld a, -PAUSE_WINDOW_SPEED
    ld [Ram_PauseWindowVelocity_i8], a
    ;; fall through to Main_PausingGame

Main_PausingGame:
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_AnimateTiles
    xcall FuncX_DrawPause_DrawNextWindowRow
_PausingGame_MoveWindow:
    ld hl, Ram_PauseWindowVelocity_i8
    ldh a, [rWY]
    add [hl]
    ldh [rWY], a
    call Func_PauseMenuResetHlcd
    ldh a, [rWY]
    if_eq (SCRN_Y - PAUSE_WINDOW_HEIGHT), jp, Main_PauseMenu
    if_eq SCRN_Y, jr, _PausingGame_Unpause
_PausingGame_HandleButtonStart:
    call Func_UpdateButtonState
    ldh a, [Hram_ButtonsPressed_u8]
    bit PADB_START, a
    jr z, .noPress
    ld a, [Ram_PauseWindowVelocity_i8]
    neg
    ld [Ram_PauseWindowVelocity_i8], a
    .noPress
    jr Main_PausingGame
_PausingGame_Unpause:
    ;; Show objects and hide the window.
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16
    ldh [rLCDC], a
    ;; Disable LY=LYC interrupt.
    ld a, IEF_VBLANK
    ldh [rIE], a
    jp Main_PuzzleCommand

;;;=========================================================================;;;

Main_PauseMenu:
    call Func_UpdateAudio
    call Func_WaitForVBlank
    call Func_AnimateTiles
    call Func_PauseMenuResetHlcd
    call Func_UpdateButtonState
_PauseMenu_HandleButtons:
    ldh a, [Hram_ButtonsPressed_u8]
    ld b, a
    and PADF_START | PADF_A
    jr nz, _PauseMenu_Confirm
    bit PADB_B, b
    jr nz, _PauseMenu_Unpause
    bit PADB_UP, b
    jr nz, _PauseMenu_Up
    bit PADB_DOWN, b
    jr nz, _PauseMenu_Down
    jr Main_PauseMenu

_PauseMenu_Up:
    ld d, " "  ; cursor tile ID
    call Func_PauseMenuSetCursorTile
    ld a, [Ram_PauseMenuItem_u8]
    sub 1
    jr nc, .noUnderflow
    ld a, PAUSE_MENU_NUM_ITEMS - 1
    .noUnderflow
    jr _PauseMenu_UpdateCursor

_PauseMenu_Down:
    ld d, " "  ; cursor tile ID
    call Func_PauseMenuSetCursorTile
    ld a, [Ram_PauseMenuItem_u8]
    inc a
    if_lt PAUSE_MENU_NUM_ITEMS, jr, .noOverflow
    xor a
    .noOverflow
    jr _PauseMenu_UpdateCursor

_PauseMenu_Confirm:
    ld a, [Ram_PauseMenuItem_u8]
    if_eq PAUSE_MENU_ITEM_QUIT, jr, _PauseMenu_QuitPuzzle
    if_eq PAUSE_MENU_ITEM_RESET, jr, _PauseMenu_ResetPuzzle
_PauseMenu_Unpause:
    ld a, PAUSE_WINDOW_SPEED
    ld [Ram_PauseWindowVelocity_i8], a
    jp Main_PausingGame

_PauseMenu_UpdateCursor:
    ld [Ram_PauseMenuItem_u8], a
    ld d, ">"  ; cursor tile ID
    call Func_PauseMenuSetCursorTile
    jr Main_PauseMenu

_PauseMenu_QuitPuzzle:
    call Func_FadeOut
    ;; Disable LY=LYC interrupt.
    ld a, IEF_VBLANK
    ldh [rIE], a
    ;; Return to the area map screen.
    ld c, 0  ; param: puzzle status
    jp Main_AreaMapResume

_PauseMenu_ResetPuzzle:
    call Func_FadeOut
    ;; Disable LY=LYC interrupt.
    ld a, IEF_VBLANK
    ldh [rIE], a
    jp Main_ResetPuzzle

;;;=========================================================================;;;

Func_PauseMenuResetHlcd:
    ld a, LOW(Hram_StatTable_hlcd_arr8)
    ldh [Hram_StatNext_hlcd_hptr], a
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | \
          LCDCF_WINON | LCDCF_WIN9C00
    ldh [rLCDC], a
    ldh a, [rWY]
    ldh [rLYC], a
    ret

;;; Sets the tile ID in the window map for the pause menu cursor.
;;; @param d Tile ID to place (should be either " " or ">").
Func_PauseMenuSetCursorTile:
    ;; Store SCRN_VX_B * Ram_PauseMenuItem_u8 in bc.
    ASSERT PAUSE_MENU_NUM_ITEMS < 8
    ASSERT SCRN_VX_B == 32
    ld a, [Ram_PauseMenuItem_u8]
    swap a
    rlca
    ldb bc, a
    ;; Make hl point to the menu cursor tile in the window map.
    ld hl, Vram_WindowMap + SCRN_VX_B * 1 + 1
    add hl, bc
    ;; Change the tile ID.
    ld [hl], d
    ret

;;;=========================================================================;;;

SECTION "DrawPause", ROMX

;;; The pause menu is laid out like this:
;;;
;;;     +========+=========+
;;;     |>Resume |Moves 123|
;;;     | Reset  |Best  057|
;;;     | Quit   |Par   048|
;;;     +========+=========+
DataX_DrawPause_2ndRow_start:
    DB "|>Resume |Moves "
DataX_DrawPause_2ndRow_end:
DataX_DrawPause_3rdRow_start:
    DB "| Reset  |Best  "
DataX_DrawPause_3rdRow_end:
DataX_DrawPause_4thRow_start:
    DB "| Quit   |Par   "
DataX_DrawPause_4thRow_end:

;;; Draws the next row of the dialog pause tile map, if there are any left to
;;; be drawn.
FuncX_DrawPause_DrawNextWindowRow:
    ld a, [Ram_PauseWindowRowsDrawn_u8]
    if_ge 5, ret
    inc a
    ld [Ram_PauseWindowRowsDrawn_u8], a
    if_eq 1, jr, _DrawPause_DrawNextWindowRow_FirstRow
    if_eq 2, jr, _DrawPause_DrawNextWindowRow_SecondRow
    if_eq 3, jr, _DrawPause_DrawNextWindowRow_ThirdRow
    if_eq 4, jr, _DrawPause_DrawNextWindowRow_FourthRow
_DrawPause_DrawNextWindowRow_LastRow:
    ld hl, Vram_WindowMap + SCRN_VX_B * 4
    jr _DrawPause_DrawNextWindowRow_FirstOrLastRow
_DrawPause_DrawNextWindowRow_FirstRow:
    ld hl, Vram_WindowMap + SCRN_VX_B * 0
_DrawPause_DrawNextWindowRow_FirstOrLastRow:
    ld a, "+"
    ld [hl+], a
    ld a, "="
    ld c, 8
    .leftLoop
    ld [hl+], a
    dec c
    jr nz, .leftLoop
    ld a, "+"
    ld [hl+], a
    ld a, "="
    ld c, 9
    .rightLoop
    ld [hl+], a
    dec c
    jr nz, .rightLoop
    ld a, "+"
    ld [hl], a
    ret
_DrawPause_DrawNextWindowRow_SecondRow:
    ld hl, Vram_WindowMap + SCRN_VX_B * 1  ; param: dest
    COPY_FROM_SAME DataX_DrawPause_2ndRow_start, DataX_DrawPause_2ndRow_end
    ld de, Ram_PuzzleNumMoves_bcd16
    jr _DrawPause_DrawNextWindowRow_DrawMoveCount
_DrawPause_DrawNextWindowRow_ThirdRow:
    ld hl, Vram_WindowMap + SCRN_VX_B * 2  ; param: dest
    COPY_FROM_SAME DataX_DrawPause_3rdRow_start, DataX_DrawPause_3rdRow_end
    ;; If the current puzzle hasn't been solved, draw dashes for the best move
    ;; count.
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    ld d, HIGH(Ram_Progress_file + FILE_PuzzleStatus_u8_arr)
    ASSERT LOW(Ram_Progress_file + FILE_PuzzleStatus_u8_arr) == 0
    ld e, a
    ld a, [de]
    bit STATB_SOLVED, a
    jr z, _DrawPause_DrawNextWindowRow_NullMoveCount
    ;; Otherwise, make de point to the best move count for the current puzzle.
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    ASSERT NUM_PUZZLES * 2 < $100
    rlca
    add LOW(Ram_Progress_file + FILE_PuzzleBest_bcd16_arr)
    ld e, a
    ld a, HIGH(Ram_Progress_file + FILE_PuzzleBest_bcd16_arr)
    adc 0
    ld d, a
    jr _DrawPause_DrawNextWindowRow_DrawMoveCount
_DrawPause_DrawNextWindowRow_FourthRow:
    ld hl, Vram_WindowMap + SCRN_VX_B * 3  ; param: dest
    COPY_FROM_SAME DataX_DrawPause_4thRow_start, DataX_DrawPause_4thRow_end
    ld de, Ram_PuzzleState_puzz + PUZZ_Par_bcd16
    jr _DrawPause_DrawNextWindowRow_DrawMoveCount
_DrawPause_DrawNextWindowRow_NullMoveCount:
    ld a, "-"
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, "|"
    ld [hl], a
    ret
_DrawPause_DrawNextWindowRow_DrawMoveCount:
    inc de
    ld a, [de]
    and $0f
    add "0"
    ld [hl+], a
    dec de
    ld a, [de]
    and $f0
    swap a
    add "0"
    ld [hl+], a
    ld a, [de]
    and $0f
    add "0"
    ld [hl+], a
    ld a, "|"
    ld [hl], a
    ret

;;;=========================================================================;;;
