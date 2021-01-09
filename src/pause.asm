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

INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"
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

;;;=========================================================================;;;

SECTION "MainPause", ROM0

Main_BeginPause::
    ;; Hide arrow objects.
    xor a
    ld [Ram_ArrowN_oama + OAMA_Y], a
    ld [Ram_ArrowS_oama + OAMA_Y], a
    ld [Ram_ArrowE_oama + OAMA_Y], a
    ld [Ram_ArrowW_oama + OAMA_Y], a
    ;; Show the window.
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | \
          LCDCF_WINON | LCDCF_WIN9C00
    ldh [rLCDC], a
    ld a, 7
    ldh [rWX], a
    ld a, SCRN_Y - PAUSE_WINDOW_SPEED
    ldh [rWY], a
    ldh [rLYC], a
    ;; Enable LY=LYC interrupt.  We have to disable interrupts before, and
    ;; clear rIF after, because writing to rSTAT can trigger a spurious STAT
    ;; interrupt.
    di
    ld a, STATF_LYC
    ldh [rSTAT], a
    ld a, IEF_VBLANK | IEF_LCDC
    ldh [rIE], a
    xor a
    ldh [rIF], a
    ei
    ;; Initialize state.
    xor a
    ld [Ram_PauseMenuItem_u8], a
    ld a, -PAUSE_WINDOW_SPEED
    ld [Ram_PauseWindowVelocity_i8], a
    ;; fall through to Main_PausingGame

Main_PausingGame:
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
_PausingGame_MoveWindow:
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | \
          LCDCF_WINON | LCDCF_WIN9C00
    ldh [rLCDC], a
    ld hl, Ram_PauseWindowVelocity_i8
    ldh a, [rWY]
    add [hl]
    ldh [rWY], a
    ldh [rLYC], a
    if_eq (SCRN_Y - PAUSE_WINDOW_HEIGHT), jp, Main_PauseMenu
    if_eq SCRN_Y, jr, _PausingGame_Unpause
_PausingGame_HandleButtonStart:
    call Func_UpdateButtonState
    ld a, [Ram_ButtonsPressed_u8]
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
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | \
          LCDCF_WINON | LCDCF_WIN9C00
    ldh [rLCDC], a
    call Func_UpdateButtonState
    ld a, [Ram_ButtonsPressed_u8]
    ld b, a
_PauseMenu_HandleButtonUp:
    bit PADB_UP, b
    jr z, .noPress
    ld d, " "  ; cursor tile ID
    call Func_PauseMenuSetCursorTile
    ld a, [Ram_PauseMenuItem_u8]
    sub 1
    jr nc, .noUnderflow
    ld a, PAUSE_MENU_NUM_ITEMS - 1
    .noUnderflow
    jr _PauseMenu_UpdateCursor
    .noPress
_PauseMenu_HandleButtonDown:
    bit PADB_DOWN, b
    jr z, .noPress
    ld d, " "  ; cursor tile ID
    call Func_PauseMenuSetCursorTile
    ld a, [Ram_PauseMenuItem_u8]
    inc a
    if_lt PAUSE_MENU_NUM_ITEMS, jr, .noOverflow
    xor a
    .noOverflow
    jr _PauseMenu_UpdateCursor
    .noPress
_PauseMenu_HandleButtonStart:
    bit PADB_START, b
    jr z, Main_PauseMenu
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
    ;; Return to map screen.
    ld c, 0  ; is victory (0=false)
    jp Main_WorldMapScreen

_PauseMenu_ResetPuzzle:
    call Func_FadeOut
    ;; Disable LY=LYC interrupt.
    ld a, IEF_VBLANK
    ldh [rIE], a
    jp Main_ResetPuzzle

;;;=========================================================================;;;

;;; Sets the tile ID in the window map for the pause menu cursor.
;;; @param d Tile ID to place (should be either " " or ">").
Func_PauseMenuSetCursorTile:
    ;; Store SCRN_VX_B * Ram_PauseMenuItem_u8 in bc.
    ASSERT PAUSE_MENU_NUM_ITEMS < 8
    ASSERT SCRN_VX_B == 32
    ld a, [Ram_PauseMenuItem_u8]
    swap a
    rlca
    ld c, a
    ld b, 0
    ;; Make hl point to the menu cursor tile in the window map.
    ld hl, Vram_WindowMap + 2 + 1 * SCRN_VX_B
    add hl, bc
    ;; Change the tile ID.
    ld [hl], d
    ret

;;;=========================================================================;;;

SECTION "PauseMenuStrings", ROM0

Data_PauseMenuString1_start::
    DB ">CONTINUE"
Data_PauseMenuString1_end::
Data_PauseMenuString2_start::
    DB " RESET PUZZLE"
Data_PauseMenuString2_end::
Data_PauseMenuString3_start::
    DB " BACK TO MAP"
Data_PauseMenuString3_end::

;;;=========================================================================;;;
