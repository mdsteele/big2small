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

NODE_TILEID  EQU $82
TRAIL_TILEID EQU $83

;;;=========================================================================;;;

SECTION "AreaMapState", WRAM0

;;; A counter that is incremented once per frame and that can be used to drive
;;; looping animations.
Ram_AreaMapAnimationClock_u8:
    DB

;;; The tileset for the current area map (using the TILESET_* enum values).
Ram_AreaMapTileset_u8:
    DB

;;; The puzzle number for node zero of this area.  Each node in the area has a
;;; puzzle number equal to the node index plus this number.
Ram_AreaMapFirstPuzzle_u8:
    DB

;;; A pointer to the start of the NODE array for this area.
Ram_AreaMapNodes_node_arr_ptr:
    DW

;;;=========================================================================;;;

SECTION "MainAreaMapScreen", ROM0

;;; @prereq LCD is off.
;;; @param c The area to load (one of the AREA_* enum values).
Main_AreaMapScreen::
    ;; Make hl point to the AREA struct corresponding to the AREA_* enum value
    ;; stored in c.
    sla c
    ld b, 0
    ld hl, Data_AreaTable_area_ptr_arr
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    romb BANK("AreaData")
_AreaMapScreen_InitMusic:
    ;; Read the banked pointer to the SONG data from the AREA struct, then
    ;; start that music playing.
    ASSERT AREA_Music_song_bptr == 0
    ld a, [hl+]
    ld c, a     ; param: bank
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    push hl
    ldw hl, de  ; param: song ptr
    call Func_MusicStart
    romb BANK("AreaData")
    pop hl
_AreaMapScreen_InitColorset:
    ;; Read the COLORSET_* enum value from the AREA struct, then load the
    ;; corresponding background color palettes.
    ASSERT AREA_Colorset_u8 == 3
    ld a, [hl+]
    push hl
    ld c, a  ; param: colorset
    xcall FuncX_SetBgColorPalettes
    romb BANK("AreaData")
    pop hl
_AreaMapScreen_InitTileset:
    ;; Read the TILESET_* enum value from the AREA struct, then load the
    ;; corresponding tile data into VRAM.
    ASSERT AREA_Tileset_u8 == 4
    ld a, [hl+]
    ld [Ram_AreaMapTileset_u8], a
    push hl
    ld b, a  ; param: tileset
    call Func_LoadTileset
    romb BANK("AreaData")
    pop hl
_AreaMapScreen_LoadTileMap:
    ;; Read the banked pointer to the BG tile map data from the AREA struct,
    ;; then copy that map data into VRAM.
    ASSERT AREA_TileMap_bptr == 5
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    push hl
    romb c
    ld hl, Vram_BgMap + SCRN_VX_B
    ld b, SCRN_VY_B - 2
    .outerLoop
    ld c, SCRN_X_B
    .innerLoop
    ld a, [de]
    inc de
    ld [hl+], a
    dec c
    jr nz, .innerLoop
    ld a, b
    ld bc, SCRN_VX_B - SCRN_X_B
    add hl, bc
    ld b, a
    dec b
    jr nz, .outerLoop
    romb BANK("AreaData")
    pop hl
    ;; TODO: Load color palette numbers into the BG tile map.
_AreaMapScreen_DrawAreaTitle:
    ;; Copy the area title to the BG tile map.
    ASSERT AREA_Title_u8_arr20 == 8
    ld de, Vram_BgMap
    ld c, 20
    .loop
    ld a, [hl+]
    ld [de], a
    inc de
    dec c
    jr nz, .loop
_AreaMapScreen_StoreNodeMetadata:
    ;; Read and store the first puzzle number for later.
    ASSERT AREA_FirstPuzzle_u8 == 28
    ld a, [hl+]
    ld [Ram_AreaMapFirstPuzzle_u8], a
    ;; Read the number of nodes and put it in c.
    ASSERT AREA_NumNodes_u8 == 29
    ld a, [hl+]
    ld c, a
    ;; Store the pointer to the nodes array for later.
    ASSERT AREA_Nodes_node_arr == 30
    ld a, l
    ld [Ram_AreaMapNodes_node_arr_ptr + 0], a
    ld a, h
    ld [Ram_AreaMapNodes_node_arr_ptr + 1], a
_AreaMapScreen_DrawUnlockedNodes:
    ;; At this point, c holds the number of nodes in this area.
    .loop
    dec c
    ;; Set de to the puzzle number for node c.
    ld a, [Ram_AreaMapFirstPuzzle_u8]
    add c
    ldb de, a
    ;; Make hl point to the progress entry for puzzle number de.
    ld hl, Ram_Progress_file + FILE_PuzzleStatus_u8_arr
    add hl, de
    ;; If the puzzle is still locked, skip it.
    bit STATB_UNLOCKED, [hl]
    jr z, .loop
    ;; The puzzle is unlocked, so draw the node and its trail.
    push bc
    call Func_DrawNodeAndTrail
    pop bc
    xor a
    or c
    jr nz, .loop
_AreaMapScreen_InitState:
    xor a
    ld [Ram_AreaMapAnimationClock_u8], a
    ;; Clear node title in the BG tile map.
    call Func_ClearNodeTitle
    ;; Set up objects.
    call Func_ClearOam
    ;; TODO: Set up objects for walking around the map.
    call Func_PerformDma
    ;; Scroll area map into view.
    xor a
    ldh [rSCX], a
    ldh [rSCY], a
    ;; Turn on the LCD and fade in.
    call Func_FadeIn
_AreaMapScreen_RunLoop:
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_AnimateAreaMapTiles
    call Func_UpdateButtonState
    ld a, [Ram_ButtonsPressed_u8]
    ;; TODO: support walking around on the map
    bit PADB_START, a
    jr z, _AreaMapScreen_RunLoop
_AreaMapScreen_StartNextPuzzle:
    call Func_FadeOut
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    ld c, a  ; param: current puzzle number
    jp Main_BeginPuzzle

;;;=========================================================================;;;

Func_ClearNodeTitle:
    ld hl, Vram_BgMap + SCRN_VX_B * (SCRN_Y_B - 1)
    xor a
    ld c, SCRN_X_B
    .loop
    ld [hl+], a
    dec c
    jr nz, .loop
    ret

Func_AnimateAreaMapTiles:
    ld hl, Ram_AreaMapAnimationClock_u8
    inc [hl]
    ld c, [hl]  ; param: animation clock
    ld a, [Ram_AreaMapTileset_u8]
    ld b, a     ; param: tileset
    jp Func_AnimateTerrain

;;;=========================================================================;;;

;;; Draws the puzzle node and trail tick marks for the specified node within
;;; the current area.
;;; @param c The node index to draw.
Func_DrawNodeAndTrail:
    ;; Set bc to the byte offset into the NODE array.
    ASSERT sizeof_NODE == 32
    xor a
    swap c
    sla c
    rla
    ld b, a
    ;; Make hl point to the NODE struct.
    ld hl, Ram_AreaMapNodes_node_arr_ptr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
_DrawNodeAndTrail_Node:
    ;; Load position row into a and col into c.
    ASSERT NODE_Row_u8 == 0
    ld a, [hl+]
    ASSERT NODE_Col_u8 == 1
    ld c, [hl]
    inc hl
    ;; Make de point to the NODE struct's Trail array.
    ASSERT NODE_Trail_u8_arr == 2
    ldw de, hl
    ;; Make hl point to the VRAM BG map cell for the node position.
    rlca
    swap a
    ld b, a
    and %00000011
    add HIGH(Vram_BgMap)
    ld h, a
    ld a, b
    and %11100000
    ASSERT LOW(Vram_BgMap) == 0
    add c
    ld l, a
    ;; Draw the puzzle node into VRAM.
    ld [hl], NODE_TILEID
_DrawNodeAndTrail_Trail:
    ;; At this point, de points to the start of the Trail array.
    .trailLoop
    ;; If this is the last entry in the trail, we're done.  (We don't draw a
    ;; trail tick mark for the last trail entry, since in general it would be
    ;; on top of another node, or off the map).
    ld a, [de]
    bit TRAILB_END, a
    ret nz
    ;; Extract the direction from the trail entry, and set bc to the byte
    ;; offset in VRAM for one step in that direction.
    and %11110000
    if_eq TRAIL_SOUTH, jr, .south
    if_eq TRAIL_EAST, jr, .east
    if_eq TRAIL_WEST, jr, .west
    .north
    ld bc, -SCRN_VX_B
    jr .dirDone
    .south
    ld bc, SCRN_VX_B
    jr .dirDone
    .east
    ld bc, 1
    jr .dirDone
    .west
    ld bc, -1
    .dirDone
    ;; Now extract the distance from the trail entry and store it in a.
    ld a, [de]
    and %00001111
    ;; Add (bc * a) to hl, thus making hl point to the VRAM location where we
    ;; should draw the next trail tick mark.
    .distLoop
    add hl, bc
    dec a
    jr nz, .distLoop
    ;; Draw the trail tick mark into VRAM.
    ld [hl], TRAIL_TILEID
    ;; Continue to the next trail entry.
    inc de
    jr .trailLoop

;;;=========================================================================;;;
