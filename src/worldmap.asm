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
INCLUDE "src/tileset.inc"
INCLUDE "src/vram.inc"

;;;=========================================================================;;;

PUZZLE_NODE_TILEID EQU $82

;;;=========================================================================;;;

SECTION "WorldMapFunctions", ROM0

;;; @prereq LCD is off.
Main_WorldMapScreen::
    ;; Copy the tile data to VRAM.
    ld b, TILESET_MAP_WORLD  ; param: tileset
    call Func_LoadTileset
    ;; Copy the BG tile map to VRAM.
    ld hl, Vram_BgMap  ; dest
    COPY_FROM_ROMX DataX_WorldTileMap_start, DataX_WorldTileMap_end
    ;; TODO: Load color palette numbers into the BG tile map.
_WorldMapScreen_SetUpObjects:
    ;; Set up objects.
    call Func_ClearOam
    ;; TODO: Set up objects for walking around the map.
    ;; Initialize music.
    ld c, BANK(DataX_RestYe_song)
    ld hl, DataX_RestYe_song
    call Func_MusicStart
    ;; Turn on the LCD and fade in.
    call Func_ScrollMapToCurrentArea
    call Func_FadeIn
_WorldMapScreen_RunLoop:
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_UpdateButtonState
    ld a, [Ram_ButtonsPressed_u8]
    bit PADB_START, a
    jr z, _WorldMapScreen_RunLoop
_WorldMapScreen_StartNextPuzzle:
    call Func_FadeOut
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    ld c, a  ; param: puzzle number
    call Func_GetPuzzleArea_c  ; param: area
    jp Main_AreaMapEnter

;;;=========================================================================;;;

Data_AreaPositions_u8_pair_arr:
    .begin
    ASSERT @ - .begin == 2 * AREA_FOREST
    DB 28, 6
    ASSERT @ - .begin == 2 * AREA_FARM
    DB 28, 6
    ASSERT @ - .begin == 2 * AREA_MOUNTAIN
    DB 28, 6
    ASSERT @ - .begin == 2 * AREA_SEASIDE
    DB 28, 6
    ASSERT @ - .begin == 2 * AREA_SEWER
    DB 28, 6
    ASSERT @ - .begin == 2 * AREA_CITY
    DB 28, 6
    ASSERT @ - .begin == 2 * AREA_SPACE
    DB 28, 6
ASSERT @ - .begin == 2 * NUM_AREAS

;;; Set rSCX and rSCY to try to center the current area node on the screen,
;;; while clamping the camera position.
Func_ScrollMapToCurrentArea:
    ;; Make hl point to the current puzzle's position entry.
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    ld c, a
    call Func_GetPuzzleArea_c
    ld a, c
    ASSERT NUM_AREAS * 2 < $100
    rlca
    add LOW(Data_AreaPositions_u8_pair_arr)
    ld l, a
    ld a, HIGH(Data_AreaPositions_u8_pair_arr)
    adc 0
    ld h, a
_ScrollMapToCurrentArea_ScrollY:
    ;; Store row * 8 + 4 into a.
    ld a, [hl+]
    swap a
    rrca
    add 4
    ;; Clamp the camera Y position.
    if_ge SCRN_Y / 2, jr, .notLow
    xor a
    jr .setPos
    .notLow
    if_lt SCRN_VY - SCRN_Y / 2, jr, .notHigh
    ld a, SCRN_VY - SCRN_Y
    jr .setPos
    .notHigh
    sub SCRN_Y / 2
    .setPos
    ldh [rSCY], a
_ScrollMapToCurrentArea_ScrollX:
    ;; Store col * 8 + 4 into a.
    ld a, [hl]
    swap a
    rrca
    add 4
    ;; Clamp the camera X position.
    if_ge SCRN_X / 2, jr, .notLow
    xor a
    jr .setPos
    .notLow
    if_lt SCRN_VX - SCRN_X / 2, jr, .notHigh
    ld a, SCRN_VX - SCRN_X
    jr .setPos
    .notHigh
    sub SCRN_X / 2
    .setPos
    ldh [rSCX], a
    ret

;;;=========================================================================;;;
