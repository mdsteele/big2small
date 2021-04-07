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
INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"
INCLUDE "src/vram.inc"

;;;=========================================================================;;;

;;; The maximum number of lines of dialog text in the window at once.
DIALOG_NUM_TEXT_LINES EQU 3

;;; The maximum length, in tiles, of one line of dialog text.
DIALOG_TEXT_LINE_TILES EQU (SCRN_X_B - 5)

;;; The height, in pixels, of the dialog window when fully visible.
DIALOG_WINDOW_HEIGHT EQU (TILE_HEIGHT * (2 + DIALOG_NUM_TEXT_LINES))

;;; The number of pixels per frame that the window slides up/down while
;;; pausing/unpausing.
DIALOG_WINDOW_SPEED EQU 2
STATIC_ASSERT DIALOG_WINDOW_HEIGHT % DIALOG_WINDOW_SPEED == 0

;;;=========================================================================;;;

SECTION "DialogState", WRAM0

Ram_DialogBank_u8:
    DB

Ram_DialogNext_ptr:
    DW

;;; The current portrait number (one of the DIALOG_* constants).
Ram_DialogPortrait_u8:
    DB

;;; How many rows of the window tile map we've drawn so far.  (We don't draw
;;; them all at once to avoid running over the VBlank period.)
Ram_DialogWindowRowsDrawn_u8:
    DB

;;;=========================================================================;;;

SECTION "DialogFunctions", ROM0

;;; @param hl A pointer to a banked pointer to a DLOG struct.
Func_RunDialog::
    ;; Read the banked pointer that hl points to.
    ld a, [hl+]
    ld [Ram_DialogBank_u8], a
    deref hl
    ;; Read the first portrait number from the DLOG struct.  If this is a null
    ;; dialog, return immediately.
    romb [Ram_DialogBank_u8]
    ld a, [hl]
    if_eq DIALOG_END, ret
    ld [Ram_DialogPortrait_u8], a
    ;; Store the DLOG pointer for later.
    ld a, l
    ld [Ram_DialogNext_ptr + 0], a
    ld a, h
    ld [Ram_DialogNext_ptr + 1], a
    ;; Start drawing window contents.
    xor a
    ld [Ram_DialogWindowRowsDrawn_u8], a
    xcall FuncX_DrawDialog_DrawNextWindowRow
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
    ld a, SCRN_Y - DIALOG_WINDOW_SPEED
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
_RunDialog_ShowWindow:
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    xcall FuncX_DrawDialog_DrawNextWindowRow
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | \
          LCDCF_WINON | LCDCF_WIN9C00
    ldh [rLCDC], a
    ldh a, [rWY]
    sub DIALOG_WINDOW_SPEED
    ldh [rWY], a
    ldh [rLYC], a
    if_ne (SCRN_Y - DIALOG_WINDOW_HEIGHT), jr, _RunDialog_ShowWindow
_RunDialog_StartNextText:
    xcall FuncX_DrawDialog_ClearText
    ;; Load the pointer to the next DLOG frame into hl.
    ld hl, Ram_DialogNext_ptr
    deref hl
    ;; Read the next portrait number.  If there's no more dialog, start
    ;; hiding the window.
    romb [Ram_DialogBank_u8]
    ld a, [hl+]
    if_eq DIALOG_END, jr, _RunDialog_HideWindow
    ld [Ram_DialogPortrait_u8], a
    ;; Set the portrait.
    push hl
    xcall FuncX_DrawDialog_SwitchPortrait
    pop de
    ld hl, Vram_WindowMap + SCRN_VX_B * 1 + 4
_RunDialog_AdvanceText:
    ;; At this point, de points to the next character of dialog text, and hl
    ;; points to the location in the VRAM window map to draw that character.
    push de
    push hl
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | \
          LCDCF_WINON | LCDCF_WIN9C00
    ldh [rLCDC], a
    pop hl
    pop de
    ;; Read the next character of text and check for sentinel values.
    romb [Ram_DialogBank_u8]
    ld a, [de]
    inc de
    if_eq DIALOG_TEXT_EOF, jr, .eof
    if_eq DIALOG_TEXT_NEWLINE, jr, .newline
    ;; Draw the next character.
    ld [hl+], a
    jr _RunDialog_AdvanceText
    .newline
    ld a, l
    ASSERT SCRN_VX_B == 32
    and %11100000
    ld l, a
    ld bc, SCRN_VX_B + 4
    add hl, bc
    jr _RunDialog_AdvanceText
    .eof
    ld a, e
    ld [Ram_DialogNext_ptr + 0], a
    ld a, d
    ld [Ram_DialogNext_ptr + 1], a
_RunDialog_WaitForButton:
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | \
          LCDCF_WINON | LCDCF_WIN9C00
    ldh [rLCDC], a
    call Func_UpdateButtonState
    ld a, [Ram_ButtonsPressed_u8]
    or a
    jr nz, _RunDialog_StartNextText
    jr _RunDialog_WaitForButton

_RunDialog_HideWindow:
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | \
          LCDCF_WINON | LCDCF_WIN9C00
    ldh [rLCDC], a
    ldh a, [rWY]
    add DIALOG_WINDOW_SPEED
    ldh [rWY], a
    ldh [rLYC], a
    if_ne SCRN_Y, jr, _RunDialog_HideWindow
_RunDialog_Finish:
    ;; Show objects and hide the window.
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16
    ldh [rLCDC], a
    ;; Disable LY=LYC interrupt.
    ld a, IEF_VBLANK
    ldh [rIE], a
    ret

;;;=========================================================================;;;

SECTION "DrawDialog", ROMX

CLEAR_TEXT_UNROLL EQU 3

;;; Blanks out all three lines of dialog text in the window map (while leaving
;;; the dialog portrait alone).
FuncX_DrawDialog_ClearText:
    ld a, " "
    ld de, SCRN_VX_B - DIALOG_TEXT_LINE_TILES
    ld hl, Vram_WindowMap + SCRN_VX_B * 1 + 4
    ld b, DIALOG_NUM_TEXT_LINES
    .outerLoop
    ASSERT DIALOG_TEXT_LINE_TILES % CLEAR_TEXT_UNROLL == 0
    ld c, DIALOG_TEXT_LINE_TILES / CLEAR_TEXT_UNROLL
    .innerLoop
    REPT CLEAR_TEXT_UNROLL
    ld [hl+], a
    ENDR
    dec c
    jr nz, .innerLoop
    dec b
    ret z
    add hl, de
    jr .outerLoop

;;; Draws the next row of the dialog window tile map, if there are any left to
;;; be drawn.
FuncX_DrawDialog_DrawNextWindowRow:
    ld a, [Ram_DialogWindowRowsDrawn_u8]
    if_ge 5, ret
    inc a
    ld [Ram_DialogWindowRowsDrawn_u8], a
    if_eq 1, jr, _DrawDialog_DrawNextWindowRow_FirstRow
    if_eq 2, jr, _DrawDialog_DrawNextWindowRow_SecondRow
    if_eq 3, jr, _DrawDialog_DrawNextWindowRow_ThirdRow
    if_eq 4, jr, _DrawDialog_DrawNextWindowRow_FourthRow
_DrawDialog_DrawNextWindowRow_LastRow:
    ld hl, Vram_WindowMap + SCRN_VX_B * 4
    jr _DrawDialog_DrawNextWindowRow_FirstOrLastRow
_DrawDialog_DrawNextWindowRow_FirstRow:
    ld hl, Vram_WindowMap + SCRN_VX_B * 0
_DrawDialog_DrawNextWindowRow_FirstOrLastRow:
    ld d, "="
    ld e, "+"
    jp FuncX_DrawDialog_DrawWindowRow
_DrawDialog_DrawNextWindowRow_SecondRow:
    ld hl, Vram_WindowMap + SCRN_VX_B * 1
    jr _DrawDialog_DrawNextWindowRow_SecondOrThirdRow
_DrawDialog_DrawNextWindowRow_ThirdRow:
    ld hl, Vram_WindowMap + SCRN_VX_B * 2
_DrawDialog_DrawNextWindowRow_SecondOrThirdRow:
    ld d, " "
    ld e, "|"
    jp FuncX_DrawDialog_DrawWindowRow
_DrawDialog_DrawNextWindowRow_FourthRow:
    ld hl, Vram_WindowMap + SCRN_VX_B * 3
    ld d, " "
    ld e, "|"
    call FuncX_DrawDialog_DrawWindowRow
    jp FuncX_DrawDialog_SwitchPortrait

;;; Draws one row of the dialog window frame.
;;; @param d Middle tile ID.
;;; @param e Edge tile ID.
;;; @param hl Pointer to the start of a VRAM map row.
FuncX_DrawDialog_DrawWindowRow:
    ld a, e
    ld [hl+], a
    ld a, d
    ld c, SCRN_X_B - 2
    .loop
    ld [hl+], a
    dec c
    jr nz, .loop
    ld a, e
    ld [hl], a
    ret

;;; Sets tiles in the window map for the current dialog portrait.
FuncX_DrawDialog_SwitchPortrait:
    ;; Set bc to the current portrait number times 9.
    ld a, [Ram_DialogPortrait_u8]
    ld c, a
    swap a
    rrca
    add c
    ldb bc, a
    ;; Make hl point to start of portrait table entry.
    ld hl, DataX_DrawDialog_PortraitTable_u8_arr9_arr
    add hl, bc
    ;; Set the window tiles.
WINDOW_ROW = 1
    REPT 3
    ld de, Vram_WindowMap + SCRN_VX_B * WINDOW_ROW + 1
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
WINDOW_ROW = WINDOW_ROW + 1
    ENDR
    ret

DataX_DrawDialog_PortraitTable_u8_arr9_arr:
    .begin
    ASSERT @ - .begin == 9 * DIALOG_ELEPHANT_EYES_OPEN
    DB $4b, $4e, $51, $4c, $4f, $52, $4d, $50, $53
    ASSERT @ - .begin == 9 * DIALOG_ELEPHANT_EYES_CLOSED
    DB $4b, $4e, $51, $66, $67, $52, $4d, $50, $53
    ASSERT @ - .begin == 9 * DIALOG_GOAT_MOUTH_CLOSED
    DB $54, $57, $5a, $55, $58, $5b, $56, $59, $5c
    ASSERT @ - .begin == 9 * DIALOG_GOAT_MOUTH_OPEN
    DB $54, $57, $5a, $55, $58, $5b, $56, $59, $63
    ASSERT @ - .begin == 9 * DIALOG_MOUSE
    DB $5d, $60, $00, $5e, $61, $64, $5f, $62, $65
    ASSERT @ - .begin == 9 * DIALOG_END

;;;=========================================================================;;;
