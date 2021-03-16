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

AVATAR_PALETTE EQU (OAMF_PAL0 | 1)

AVATAR_S1_TILEID EQU $68
AVATAR_N1_TILEID EQU $6a
AVATAR_W1_TILEID EQU $6c

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

;;; A pointer to the start of the NODE array in BANK("AreaData") for the
;;; current area.
Ram_AreaMapNodes_node_arr_ptr:
    DW

;;; The index of the currently selected node.
Ram_AreaMapCurrentNode_u8:
    DB

;;; The BG tile row on the area map where the avatar is currently located.
Ram_AreaMapAvatarRow_u8:
    DB

;;; The BG tile column on the area map where the avatar is currently located.
Ram_AreaMapAvatarCol_u8:
    DB

;;;=========================================================================;;;

SECTION "MainAreaMap", ROM0

;;; Runs the area map screen for the specified area, with the avatar walking in
;;; from the area entrance.
;;; @prereq LCD is off.
;;; @param c The area to load (one of the AREA_* enum values).
Main_AreaMapEnter::
    call Func_LoadAreaMap
    ;; Turn on the LCD and fade in.
    call Func_FadeIn
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ8
    ldh [rLCDC], a
    ;; Unlock the first node if needed.
    ld c, 0  ; param: node index to unlock
    call Func_UnlockNode
    ;; Walk the avatar in from the entrance.
    ld d, 0  ; param: destination node
    ld c, d  ; param: trail node
    jp Main_AreaMapFollowTrail

;;; Runs the area map screen for the current puzzle's area, with the avatar
;;; starting at the node for the current puzzle.
;;; @param c 1 if the current puzzle was just solved, 0 otherwise.
;;; @prereq LCD is off.
Main_AreaMapResume::
    push bc
    ;; Load the area map for the current puzzle.
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    ld c, a  ; param: puzzle number
    call Func_GetPuzzleArea_c  ; param: area to load
    call Func_LoadAreaMap
    ;; Place the avatar at the node for the current puzzle.
    ld a, [Ram_AreaMapFirstPuzzle_u8]
    ld b, a
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    sub b
    ld [Ram_AreaMapCurrentNode_u8], a
    call Func_PlaceAvatarAtCurrentNode
    ;; Turn on the LCD and fade in.
    call Func_FadeIn
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ8
    ldh [rLCDC], a
    ;; If the current puzzle wasn't just solved, then we're done.
    pop bc
    bit 0, c
    jp z, Main_AreaMapCommand
    ;; If the current puzzle wasn't already solved, then mark it solved and
    ;; increment the number of solved puzzles.
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    ld h, HIGH(Ram_Progress_file + FILE_PuzzleStatus_u8_arr)
    ASSERT LOW(Ram_Progress_file + FILE_PuzzleStatus_u8_arr) == 0
    ld l, a
    bit STATB_SOLVED, [hl]
    jr nz, .alreadySolved
    set STATB_SOLVED, [hl]
    ld a, [Ram_Progress_file + FILE_NumSolvedPuzzles_bcd8]
    add 1
    daa
    ld [Ram_Progress_file + FILE_NumSolvedPuzzles_bcd8], a
    ;; TODO: If the next node is the exit node, draw the area's exit trail.
    .alreadySolved
    ;; Unlock the next puzzle.
    call Func_GetPointerToCurrentNode_hl
    ld bc, NODE_Next_u8
    add hl, bc
    ld a, [hl]
    and $0f
    ld c, a  ; param: node index to unlock
    call Func_UnlockNode
    ;; TODO: Unlock bonus puzzle, if applicable.
    ;; Save progress.
    call Func_SaveFile
    ;; TODO: If we just unlocked the next puzzle for the first time, use
    ;;   Main_AreaMapFollowTrail to walk to it.
    jp Main_AreaMapCommand

;;; @prereq LCD is off.
;;; @param c The area to load (one of the AREA_* enum values).
Func_LoadAreaMap:
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
_LoadAreaMap_InitMusic:
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
_LoadAreaMap_InitColorset:
    ;; Read the COLORSET_* enum value from the AREA struct, then load the
    ;; corresponding background color palettes.
    ASSERT AREA_Colorset_u8 == 3
    ld a, [hl+]
    push hl
    ld c, a  ; param: colorset
    xcall FuncX_SetBgColorPalettes
    romb BANK("AreaData")
    pop hl
_LoadAreaMap_InitTileset:
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
_LoadAreaMap_LoadTileMap:
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
    push de
    romb c
    ld hl, Vram_BgMap + SCRN_VX_B
    ld b, SCRN_VY_B - 2
    .rowLoop
    ld c, SCRN_X_B
    .colLoop
    ld a, [de]
    inc de
    ld [hl+], a
    dec c
    jr nz, .colLoop
    ld a, b
    ld bc, SCRN_VX_B - SCRN_X_B
    add hl, bc
    ld b, a
    dec b
    jr nz, .rowLoop
_LoadAreaMap_SetBgColorData:
    ;; Make de again point to the BG tile map data for this area.  At this
    ;; point, the ROM bank is still set to the bank for this data.
    pop de  ; param: BG tile map pointer
    ;; If color is enabled, load color data into VRAM.
    ldh a, [Hram_ColorEnabled_bool]
    or a
    call nz, Func_LoadAreaMapColor
    ;; Resume reading the AREA struct where we left off.
    romb BANK("AreaData")
    pop hl
_LoadAreaMap_DrawAreaTitle:
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
_LoadAreaMap_StoreNodeMetadata:
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
_LoadAreaMap_DrawUnlockedNodes:
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
_LoadAreaMap_InitState:
    xor a
    ld [Ram_AreaMapAnimationClock_u8], a
    ldh [rSCX], a
    ldh [rSCY], a
    call Func_ClearOam
    ;; Clear node title in the BG tile map.
    jp Func_ClearNodeTitle

;;;=========================================================================;;;

;;; If the puzzle of the specified node isn't already unlocked, marks that
;;; puzzle as unlocked and animates drawing the trail for that node.
;;; @param c The node index to unlock.
Func_UnlockNode:
    ;; Do nothing for the exit node.
    ld a, c
    if_eq EXIT_NODE, ret
    ;; Make hl point to the progress status entry for the puzzle of the node to
    ;; unlock.
    ld a, [Ram_AreaMapFirstPuzzle_u8]
    add c
    ld h, HIGH(Ram_Progress_file + FILE_PuzzleStatus_u8_arr)
    ASSERT LOW(Ram_Progress_file + FILE_PuzzleStatus_u8_arr) == 0
    ld l, a
    ;; If the puzzle is already unlocked, we're done.
    bit STATB_UNLOCKED, [hl]
    ret nz
    ;; Mark the puzzle as unlocked.
    set STATB_UNLOCKED, [hl]
    ;; TODO: Animate drawing the trail.
    ret

;;;=========================================================================;;;

;;; Animates the avatar and map while waiting for the player to press a button,
;;; then takes appropriate action.
Main_AreaMapCommand:
    call Func_UpdateAudio
    call Func_UpdateAreaMapAvatarObj
    call Func_WaitForVBlankAndPerformDma
    call Func_AnimateAreaMapTiles
    call Func_UpdateButtonState
_AreaMapCommand_HandleButtons:
    ld a, [Ram_ButtonsPressed_u8]
    ld d, a
    and PADF_START | PADF_A
    jp nz, Main_AreaMapStartNextPuzzle
    bit PADB_B, d
    jp nz, Main_AreaMapBackToWorldMap
_AreaMapCommand_HandleDpad:
    ld a, d
    and PADF_UP | PADF_DOWN | PADF_LEFT | PADF_RIGHT
    jr z, Main_AreaMapCommand
    ld d, a
    call Func_GetPointerToCurrentNode_hl  ; preserves d
    ld bc, NODE_Prev_u8
    add hl, bc
    ld a, [hl+]
    ld e, a
    and d
    jr nz, _AreaMapCommand_FollowPrevTrail
    ASSERT NODE_Next_u8 == 1 + NODE_Prev_u8
    ld a, [hl+]
    ld e, a
    and d
    jr nz, _AreaMapCommand_FollowNextTrail
    ASSERT NODE_Bonus_u8 == 1 + NODE_Next_u8
    ld a, [hl+]
    ld e, a
    and d
    jr nz, _AreaMapCommand_FollowBonusTrail
_AreaMapCommand_CannotMove:
    ld c, BANK(DataX_CannotMove_sfx1)
    ld hl, DataX_CannotMove_sfx1
    call Func_PlaySfx1
    jr Main_AreaMapCommand

_AreaMapCommand_FollowPrevTrail:
    ;; At this point, e holds the current node's NODE_Prev_u8 field value.
    ;; Follow the trail to the previous node.
    ld a, e
    and $0f
    ld d, a  ; param: destination node
    ld a, [Ram_AreaMapCurrentNode_u8]
    ld c, a  ; param: trail node
    jp Main_AreaMapFollowTrail

_AreaMapCommand_FollowNextTrail:
    ;; Set a to the current node's puzzle number.
    ld a, [Ram_AreaMapFirstPuzzle_u8]
    ld b, a
    ld a, [Ram_AreaMapCurrentNode_u8]
    add b
    ;; Check if this puzzle is solved.  If not, we can't go to the next node.
    ld h, HIGH(Ram_Progress_file + FILE_PuzzleStatus_u8_arr)
    ASSERT LOW(Ram_Progress_file + FILE_PuzzleStatus_u8_arr) == 0
    ld l, a
    bit STATB_SOLVED, [hl]
    jr z, _AreaMapCommand_CannotMove
    ;; At this point, e holds the current node's NODE_Next_u8 field value.
    ;; Follow the trail to the next node.
    ld a, e
    and $0f
    ld d, a  ; param: destination node
    ld c, d  ; param: trail node
    jp Main_AreaMapFollowTrail

_AreaMapCommand_FollowBonusTrail:
    ;; At this point, e holds the current node's NODE_Bonus_u8 field value.
    ld a, e
    and $0f
    ld d, a  ; param: destination node
    ;; Set a to the bonus node's puzzle number.
    ld a, [Ram_AreaMapFirstPuzzle_u8]
    add d
    ;; Check if the bonus puzzle is unlocked.  If not, we can't go there.
    ld h, HIGH(Ram_Progress_file + FILE_PuzzleStatus_u8_arr)
    ASSERT LOW(Ram_Progress_file + FILE_PuzzleStatus_u8_arr) == 0
    ld l, a
    bit STATB_UNLOCKED, [hl]
    jr z, _AreaMapCommand_CannotMove
    ;; Follow the trail to the bonus node.
    ld c, d  ; param: trail node
    jp Main_AreaMapFollowTrail

;;;=========================================================================;;;

;;; Animates the area map avatar walking from node to node, then switches modes
;;; appropariately depending on whether the destination is an exit node.
;;; @param c The node index of the trail to follow.
;;; @param d The destination node index.
Main_AreaMapFollowTrail:
    ;; TODO: Animate walking the trail, forwards if c != d, else backwards.
    ;; TODO: If c == EXIT_NODE, we need to follow the area's exit trail.
    ;; TODO: Blank out the origin node's title while walking.
    ld a, d
    if_eq EXIT_NODE, jp, Main_AreaMapBackToWorldMap
    ld [Ram_AreaMapCurrentNode_u8], a
    call Func_PlaceAvatarAtCurrentNode
    jp Main_AreaMapCommand

;;;=========================================================================;;;

;;; Fades out the LCD and returns to the world map screen.
Main_AreaMapBackToWorldMap:
    call Func_ClearOam
    call Func_FadeOut
    jp Main_WorldMapScreen

;;; Fades out the LCD and starts the puzzle for the current node.
Main_AreaMapStartNextPuzzle:
    call Func_ClearOam
    call Func_FadeOut
    ;; Set a to the current node's puzzle number.
    ld a, [Ram_AreaMapFirstPuzzle_u8]
    ld b, a
    ld a, [Ram_AreaMapCurrentNode_u8]
    add b
    ;; Save the current puzzle number.
    ld [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8], a
    call Func_SaveFile
    ;; Start the current puzzle.
    ld a, [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8]
    ld c, a  ; param: current puzzle number
    jp Main_BeginPuzzle

;;;=========================================================================;;;

;;; Returns a pointer to the current NODE struct and switches to the ROM bank
;;; that NODE struct is stored in.
;;; @return hl A pointer to the current NODE struct.
;;; @preserve de
Func_GetPointerToCurrentNode_hl:
    ld a, [Ram_AreaMapCurrentNode_u8]
    ld c, a
    ;; fall through to Func_GetPointerToNode_hl

;;; Returns a pointer to the specified NODE struct and switches to the ROM bank
;;; that NODE struct is stored in.
;;; @param c The index of the NODE struct to get a pointer to.
;;; @return hl A pointer to the specified NODE struct.
;;; @preserve de
Func_GetPointerToNode_hl:
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
    ;; Switch to the ROM bank that holds the NODE struct.
    romb BANK("AreaData")
    ret

;;;=========================================================================;;;

;;; Writes a row of spaces to VRAM on the bottom BG tile row of the screen.
Func_ClearNodeTitle:
    ld hl, Vram_BgMap + SCRN_VX_B * (SCRN_Y_B - 1)
    xor a
    ld c, SCRN_X_B
    .loop
    ld [hl+], a
    dec c
    jr nz, .loop
    ret

;;; Increments Ram_AreaMapAnimationClock_u8 and updates animated terrain in
;;; VRAM as needed.
Func_AnimateAreaMapTiles:
    ld hl, Ram_AreaMapAnimationClock_u8
    inc [hl]
    ld c, [hl]  ; param: animation clock
    ld a, [Ram_AreaMapTileset_u8]
    ld b, a     ; param: tileset
    jp Func_AnimateTerrain

;;; Sets Ram_AreaMapAvatarRow_u8 and Ram_AreaMapAvatarCol_u8 to the row/col of
;;; the current node, and writes the current node's title to VRAM on the bottom
;;; BG tile row of the screen.
Func_PlaceAvatarAtCurrentNode:
    call Func_GetPointerToCurrentNode_hl
    ;; Set the avatar's row/col.
    ASSERT NODE_Row_u8 == 0
    ld a, [hl+]
    ld [Ram_AreaMapAvatarRow_u8], a
    ASSERT NODE_Col_u8 == 1
    ld a, [hl]
    ld [Ram_AreaMapAvatarCol_u8], a
    ;; Draw the node's title on the bottom row of the screen.
    ld bc, NODE_Title_u8_arr16 - NODE_Col_u8
    add hl, bc
    ld de, Vram_BgMap + SCRN_VX_B * (SCRN_Y_B - 1) + 2
    ld c, 16
    .titleLoop
    ld a, [hl+]
    ld [de], a
    inc de
    dec c
    jr nz, .titleLoop
    ret

;;; Updates the shadow OAMA struct for the area map avatar.
Func_UpdateAreaMapAvatarObj:
    ;; Set Y position:
    ld a, [Ram_AreaMapAvatarRow_u8]
    swap a
    rrca
    add 13
    ld [Ram_ElephantL_oama + OAMA_Y], a
    ;; Set X position:
    ld a, [Ram_AreaMapAvatarCol_u8]
    swap a
    rrca
    add 7
    ld [Ram_ElephantL_oama + OAMA_X], a
    ;; Set tile ID:
    ld a, [Ram_AreaMapAnimationClock_u8]
    and %00010000
    swap a
    ;; TODO: Don't always face south.
    add AVATAR_S1_TILEID
    ld [Ram_ElephantL_oama + OAMA_TILEID], a
    ;; Set flags:
    ld a, AVATAR_PALETTE
    ;; TODO: Set horizontal flip flag as needed.
    ld [Ram_ElephantL_oama + OAMA_FLAGS], a
    ret

;;;=========================================================================;;;

;;; Draws the puzzle node and trail tick marks for the specified node within
;;; the current area.
;;; @prereq ROM bank is set to BANK("AreaData").
;;; @param c The node index to draw.
Func_DrawNodeAndTrail:
    call Func_GetPointerToNode_hl
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

;;; @prereq Correct ROM bank for de pointer is set.
;;; @param de Pointer to the BG map data for the area.
Func_LoadAreaMapColor:
    ;; Copy the palette table into HRAM for later.
    ld hl, Data_AreaMapBgPalettes_u8_arr8
    ld c, LOW(Hram_AreaMapBgPalettes_u8_arr8)
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
    ;; Set the color palettes for the area map based on the tile IDs.
    ld hl, Vram_BgMap + SCRN_VX_B
    REPT SCRN_Y_B - 2
    call Func_LoadAreaMapColorRow
    ENDR
    ;; Set the color palette for the top and bottom rows of tiles (where the
    ;; area and puzzle titles go) to 0.
    xor a
    ld hl, Vram_BgMap
    ld c, SCRN_X_B
    .topRowLoop
    ld [hl+], a
    dec c
    jr nz, .topRowLoop
    ld hl, Vram_BgMap + SCRN_VX_B * (SCRN_Y_B - 1)
    ld c, SCRN_X_B
    .botRowLoop
    ld [hl+], a
    dec c
    jr nz, .botRowLoop
    ;; Switch back to VRAM bank 0.
    xor a
    ldh [rVBK], a
    ret

;;; @prereq Hram_AreaMapBgPalettes_u8_arr8 has been populated.
;;; @prereq Correct ROM bank for de pointer is set.
;;; @prereq VRAM bank is set to 1.
;;; @param de Pointer to start of area tile map row.
;;; @param hl Pointer to start of Vram_BgMap row.
;;; @return de Pointer to start of next area tile map row.
;;; @return hl Pointer to start of next Vram_BgMap row.
Func_LoadAreaMapColorRow:
    ld b, SCRN_X_B
    .colLoop
    ;; Get next tile map value.
    ld a, [de]
    inc de
    ;; Use bits 4-6 as an index into Hram_AreaMapBgPalettes_u8_arr8.
    and %01110000
    swap a
    add LOW(Hram_AreaMapBgPalettes_u8_arr8)
    ld c, a
    ld a, [c]
    ;; Write the palette from the table into VRAM.
    ld [hl+], a
    dec b
    jr nz, .colLoop
    ;; Set up hl for next row.
    ld bc, SCRN_VX_B - SCRN_X_B
    add hl, bc
    ret

;;; Maps from bits 4-6 of an area map tile ID to a color palette number.
Data_AreaMapBgPalettes_u8_arr8:
    DB 5, 1, 1, 1, 7, 6, 4, 1

;;;=========================================================================;;;

SECTION "HramAreaMapBgPalettes", HRAM

;;; Helper memory for Func_LoadAreaMapColor that holds a temporary copy of
;;; Data_AreaMapBgPalettes_u8_arr8.
Hram_AreaMapBgPalettes_u8_arr8:
    DS 8

;;;=========================================================================;;;
