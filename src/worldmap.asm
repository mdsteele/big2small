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

SECTION "WorldMapState", WRAM0

;;; A counter that is incremented once per frame and that can be used to drive
;;; looping animations.
Ram_WorldMapAnimationClock_u8:
    DB

;;; The currently selected area (one of the AREA_* enum values).
Ram_WorldMapCurrentArea_u8:
    DB

;;; The furthest area that's currently unlocked (one of the AREA* enum values).
Ram_WorldMapLastUnlockedArea_u8:
    DB

;;;=========================================================================;;;

SECTION "WorldMapFunctions", ROM0

;;; @prereq LCD is off.
;;; @param c The current area (one of the AREA_* enum values).
Main_WorldMapScreen::
    call Func_WorldMapSetCurrentArea
    xor a
    ld [Ram_WorldMapAnimationClock_u8], a
_WorldMapScreen_LoadTileMap:
    ;; Copy the tile data to VRAM.
    ld b, TILESET_MAP_WORLD  ; param: tileset
    call Func_LoadTileset
    ;; Copy the BG tile map to VRAM.
    ld hl, Vram_BgMap  ; param: dest
    COPY_FROM_ROMX DataX_WorldTileMap_start, DataX_WorldTileMap_end
    ;; If color is enabled, load color data into VRAM.
    ldh a, [Hram_ColorEnabled_bool]
    or a
    call nz, Func_LoadWorldMapColor
_WorldMapScreen_SetUnlockedAreas:
    ;; Determine which areas are unlocked.  We start by assuming that all areas
    ;; up to and including the current area are unlocked.  We'll use e to store
    ;; the furthest unlocked area so far.
    ld a, [Ram_WorldMapCurrentArea_u8]
    ld e, a
    romb BANK("AreaData")
    .areaLoop
    ;; Set a to the next area to consider.  If e is already the last area, then
    ;; we're done.
    ld a, e
    inc a
    if_eq NUM_AREAS, jr, .areaDone
    ;; Make hl point to the AREA struct for area c.
    ld c, a  ; param: area number
    call Func_GetAreaData_hl  ; preserves e
    ;; Set l to the last puzzle before area a.
    ld bc, AREA_FirstPuzzle_u8
    add hl, bc
    ld l, [hl]
    dec l
    ;; Make hl point to the progress status entry for puzzle l.
    ASSERT LOW(Ram_Progress_file + FILE_PuzzleStatus_u8_arr) == 0
    ld h, HIGH(Ram_Progress_file + FILE_PuzzleStatus_u8_arr)
    ;; If that puzzle isn't solved, then we're done.
    bit STATB_SOLVED, [hl]
    jr z, .areaDone
    ;; The next area is indeed unlocked, so increment e and continue.
    inc e
    jr .areaLoop
    ;; When the loop finishes, e holds the furthest unlocked area.
    .areaDone
    ld a, e
    ld [Ram_WorldMapLastUnlockedArea_u8], a
_WorldMapScreen_SetUpObjects:
    ;; Set up objects.
    call Func_ClearOam
    ;; TODO: Set up objects for walking around the map.
    ;; Initialize music.
    PLAY_SONG DataX_RestYe_song
    ;; Turn on the LCD and fade in.
    call Func_ScrollMapToCurrentArea
    call Func_FadeIn
    ;; Set up window.
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ8 | \
          LCDCF_WINON | LCDCF_WIN9C00
    ldh [rLCDC], a
    ld a, 7
    ldh [rWX], a
    ld a, SCRN_Y - 8
    ldh [rWY], a
    ;; fall through to Main_WorldMapCommand

;;; Animates the map while waiting for the player to press a button, then takes
;;; appropriate action.
Main_WorldMapCommand:
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_WorldMapAnimateTiles
    call Func_UpdateButtonState
_AreaMapCommand_HandleButtons:
    ld a, [Ram_ButtonsPressed_u8]
    ld d, a
    and PADF_START | PADF_A
    jr nz, _WorldMapCommand_EnterArea
    bit PADB_LEFT, d
    jr nz, _WorldMapCommand_PrevArea
    bit PADB_RIGHT, d
    jr nz, _WorldMapCommand_NextArea
    jr Main_WorldMapCommand

_WorldMapCommand_PrevArea:
    ld a, [Ram_WorldMapCurrentArea_u8]
    or a
    jr z, Main_WorldMapCommand
    dec a
    ld c, a  ; param: area number
    call Func_WorldMapSetCurrentArea
    jr Main_WorldMapCommand

_WorldMapCommand_NextArea:
    ld a, [Ram_WorldMapLastUnlockedArea_u8]
    ld c, a
    ld a, [Ram_WorldMapCurrentArea_u8]
    if_eq c, jr, Main_WorldMapCommand
    inc a
    ld c, a  ; param: area number
    call Func_WorldMapSetCurrentArea
    jr Main_WorldMapCommand

_WorldMapCommand_EnterArea:
    call Func_FadeOut
    ld a, [Ram_WorldMapCurrentArea_u8]
    ld c, a  ; param: area number
    jp Main_AreaMapEnter

;;;=========================================================================;;;

;;; Increments Ram_WorldMapAnimationClock_u8 and updates animated terrain in
;;; VRAM as needed.
Func_WorldMapAnimateTiles:
    ld hl, Ram_WorldMapAnimationClock_u8
    inc [hl]
    ld c, [hl]              ; param: animation clock
    ld b, TILESET_MAP_WORLD ; param: tileset
    jp Func_AnimateTerrain

;;; Makes the specified area the currently selected area for the world map, and
;;; puts that area's title on the screen.
;;; @param c The area to make current (one of the AREA_* enum values).
Func_WorldMapSetCurrentArea:
    ;; Set the current area.
    ld a, c
    ld [Ram_WorldMapCurrentArea_u8], a
    ;; Make hl point to the title of area c.
    call Func_GetAreaData_hl
    ld bc, AREA_Title_u8_arr20
    add hl, bc
    ;; Draw the area title to the window map in VRAM.
    ld de, Vram_WindowMap
    ld c, 20
    .titleLoop
    ld a, [hl+]
    ld [de], a
    inc de
    dec c
    jr nz, .titleLoop
    ;; Scroll the map.
    jp Func_ScrollMapToCurrentArea

;;;=========================================================================;;;

Data_AreaPositions_u8_pair_arr:
    .begin
    ASSERT @ - .begin == 2 * AREA_FOREST
    DB 28, 6
    ASSERT @ - .begin == 2 * AREA_FARM
    DB 28, 16
    ASSERT @ - .begin == 2 * AREA_MOUNTAIN
    DB 28, 28
    ASSERT @ - .begin == 2 * AREA_LAKE
    DB 16, 28
    ASSERT @ - .begin == 2 * AREA_SEWER
    DB 16, 16
    ASSERT @ - .begin == 2 * AREA_CITY
    DB 16, 6
    ASSERT @ - .begin == 2 * AREA_SPACE
    DB 6, 6
ASSERT @ - .begin == 2 * NUM_AREAS

;;; Set rSCX and rSCY to try to center the current area node on the screen,
;;; while clamping the camera position.
Func_ScrollMapToCurrentArea:
    ;; Make hl point to the current puzzle's position entry.
    ld a, [Ram_WorldMapCurrentArea_u8]
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

Func_LoadWorldMapColor:
    ;; Copy the palette table into HRAM for later.
    ld hl, Data_WorldMapBgPalettes_u8_arr8
    ld c, LOW(Hram_WorldMapBgPalettes_u8_arr8)
    ld b, 8
    .hramLoop
    ld a, [hl+]
    ld [c], a
    inc c
    dec b
    jr nz, .hramLoop
    ;; Switch to VRAM bank 1.
    ld a, 1
    ldh [rVBK], a
    ;; Load the color data into VRAM.
    ld hl, Vram_BgMap
    xld de, DataX_WorldTileMap_start
    ASSERT $400 == DataX_WorldTileMap_end - DataX_WorldTileMap_start
    REPT 4
    call Func_LoadWorldMapColorQuarter
    ENDR
    ;; Switch back to VRAM bank 0.
    xor a
    ldh [rVBK], a
    ret

;;; @prereq Hram_WorldMapBgPalettes_u8_arr8 has been populated.
;;; @prereq Correct ROM bank for de pointer is set.
;;; @prereq VRAM bank is set to 1.
;;; @param de Pointer to start of world tile map quarter.
;;; @param hl Pointer to start of Vram_BgMap quarter.
;;; @return de Pointer to start of next area tile map quarter.
;;; @return hl Pointer to start of next Vram_BgMap quarter.
Func_LoadWorldMapColorQuarter:
    ;; Perform $100 iterations.
    ld b, 0
    .loop
    ;; Get next tile map value.
    ld a, [de]
    inc de
    ;; Use bits 4-6 as an index into Hram_WorldMapBgPalettes_u8_arr8.
    and %01110000
    swap a
    add LOW(Hram_WorldMapBgPalettes_u8_arr8)
    ld c, a
    ld a, [c]
    ;; Write the palette from the table into VRAM.
    ld [hl+], a
    dec b
    jr nz, .loop
    ret

;;; Maps from bits 4-6 of a world map tile ID to a color palette number.
Data_WorldMapBgPalettes_u8_arr8:
    DB 5, 1, 1, 1, 1, 1, 4, 1

;;;=========================================================================;;;

SECTION "HramWorldMapBgPalettes", HRAM

;;; Helper memory for Func_LoadWorldMapColor that holds a temporary copy of
;;; Data_WorldMapBgPalettes_u8_arr8.
Hram_WorldMapBgPalettes_u8_arr8:
    DS 8

;;;=========================================================================;;;
