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

;;; The current area number (one of the AREA_* enum values).
Ram_AreaMapCurrentArea_u8:
    DB
;;; The tileset for the current area map (using the TILESET_* enum values).
Ram_AreaMapTileset_u8:
    DB
;;; The puzzle number for node zero of this area.  Each node in the area has a
;;; puzzle number equal to the node index plus this number.
Ram_AreaMapFirstPuzzle_u8:
    DB
;;; A pointer to the start of the current area's exit trail array in
;;; BANK("AreaData").
Ram_AreaMapExitTrail_u8_arr_ptr:
    DW
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
;;; This can be -1 if the avatar walks off the left side of the screen.
Ram_AreaMapAvatarCol_i8:
    DB
;;; The direction that the avatar is facing (one of the TRAIL_* constants).
Ram_AreaMapAvatarFacing_u8:
    DB
;;; How many pixels backwards along its facing direction to draw the avatar
;;; from its row/col tile.
Ram_AreaMapAvatarOffset_u8:
    DB

;;; The trail that the avatar is currently following, if we are in
;;; Main_AreaMapFollowTrail.  This will be a possibly-reversed copy of a node
;;; trail or area exit trail.
Ram_AreaMapWalkingTrail_u8_arr:
    DS MAX_TRAIL_LENGTH
;;; The index of the entry in Ram_AreaMapWalkingTrail_u8_arr that the avatar is
;;; currently traversing.
Ram_AreaMapWalkingIndex_u8:
    DB
;;; The node index that the avatar is walking on a trail towards (or EXIT_NODE
;;; if the avatar is leaving the area map).
Ram_AreaMapWalkingDestinationNode_u8:
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
    ld c, 0  ; param: node index
    call Func_UnlockNode
_AreaMapEnter_PositionAvatar:
    ;; Make hl point to the area's first NODE struct.
    ld c, 0  ; param: node index
    call Func_GetPointerToNode_hl
    ;; Position the avatar at the first node.
    ASSERT NODE_Row_u8 == 0
    ld a, [hl+]
    ld [Ram_AreaMapAvatarRow_u8], a
    ASSERT NODE_Col_u8 == 1
    ld a, [hl+]
    ld [Ram_AreaMapAvatarCol_i8], a
    ;; Move the avatar along the first node's trail.
    ASSERT NODE_Trail_u8_arr == 2
    .trailLoop
    ld a, [hl+]
    ld e, a  ; param: trail entry
    call Func_AreaMapAvatarApplyTrailEntry  ; preserves e and hl
    bit TRAILB_END, e
    jr z, .trailLoop
    ;; Zero the avatar's walking offset.
    xor a
    ld [Ram_AreaMapAvatarOffset_u8], a
_AreaMapEnter_WalkIn:
    ;; Walk the avatar in from the entrance.
    ld d, 0  ; param: destination node
    ld e, d  ; param: trail node
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
    ld a, TRAIL_SOUTH
    ld [Ram_AreaMapAvatarFacing_u8], a
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
    ld a, c
    ld [Ram_AreaMapCurrentArea_u8], a
    call Func_GetAreaData_hl
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
    ;; Store the exit trail pointer for later.
    ASSERT AREA_ExitTrail_u8_arr == 28
    ld a, l
    ld [Ram_AreaMapExitTrail_u8_arr_ptr + 0], a
    ld a, h
    ld [Ram_AreaMapExitTrail_u8_arr_ptr + 1], a
    ld bc, MAX_TRAIL_LENGTH
    add hl, bc
    ;; Read and store the first puzzle number for later.
    ASSERT AREA_FirstPuzzle_u8 == 39
    ld a, [hl+]
    ld [Ram_AreaMapFirstPuzzle_u8], a
    ;; Read the number of nodes and put it in c.
    ASSERT AREA_NumNodes_u8 == 40
    ld a, [hl+]
    ld c, a
    ;; Store the pointer to the nodes array for later.
    ASSERT AREA_Nodes_node_arr == 41
    ld a, l
    ld [Ram_AreaMapNodes_node_arr_ptr + 0], a
    ld a, h
    ld [Ram_AreaMapNodes_node_arr_ptr + 1], a
_LoadAreaMap_DrawExitTrail:
    ;; At this point, c holds the number of nodes in this area.
    push bc
    dec c
    ;; Set a to the puzzle number for the last node.
    ld a, [Ram_AreaMapFirstPuzzle_u8]
    add c
    ;; Make hl point to the progress entry for puzzle number a.
    ld h, HIGH(Ram_Progress_file + FILE_PuzzleStatus_u8_arr)
    ASSERT LOW(Ram_Progress_file + FILE_PuzzleStatus_u8_arr) == 0
    ld l, a
    ;; If the last puzzle isn't solved, skip drawing the exit trail.
    bit STATB_SOLVED, [hl]
    jr z, .noExitTrail
    ;; Make de point to the exit trail array.
    ld hl, Ram_AreaMapExitTrail_u8_arr_ptr
    deref de, hl
    ;; Make hl point to the VRAM BG map cell for the last node's position.
    ;; Note that for now, c is still set to the index of the last node.
    call Func_GetPointerToNode_hl  ; preserves de
    ASSERT NODE_Row_u8 == 0
    ld a, [hl+]
    ASSERT NODE_Col_u8 == 1
    ld c, [hl]
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
    ;; Draw the exit trail.
    call Func_DrawTrail
    .noExitTrail
    pop bc
_LoadAreaMap_DrawUnlockedNodes:
    ;; At this point, c holds the number of nodes in this area.
    .loop
    dec c
    ;; Set a to the puzzle number for node c.
    ld a, [Ram_AreaMapFirstPuzzle_u8]
    add c
    ;; Make hl point to the progress entry for puzzle number a.
    ld h, HIGH(Ram_Progress_file + FILE_PuzzleStatus_u8_arr)
    ASSERT LOW(Ram_Progress_file + FILE_PuzzleStatus_u8_arr) == 0
    ld l, a
    ;; If the puzzle is still locked, skip it.
    bit STATB_UNLOCKED, [hl]
    jr z, .noTrail
    ;; The puzzle is unlocked, so draw the node and its trail.
    push bc
    call Func_DrawNodeAndTrail
    pop bc
    .noTrail
    xor a
    or c
    jr nz, .loop
_LoadAreaMap_InitState:
    xor a
    ld [Ram_AreaMapAnimationClock_u8], a
    ldh [rSCX], a
    ldh [rSCY], a
    call Func_ClearOam
    jp Func_ClearAreaMapNodeTitle

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
    ld e, a  ; param: trail node
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
    ld e, d  ; param: trail node
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
    ld e, d  ; param: trail node
    jp Main_AreaMapFollowTrail

;;;=========================================================================;;;

;;; Animates the area map avatar walking from node to node, then switches modes
;;; appropariately depending on whether the destination is an exit node.
;;; @param d The destination node index (or EXIT_NODE if leaving the area).
;;; @param e The node index of the trail to use (or EXIT_NODE for exit trail).
Main_AreaMapFollowTrail:
    ;; Store the destination node index for later.
    ld a, d
    ld [Ram_AreaMapWalkingDestinationNode_u8], a
    ;; If the trail node index is EXIT_NODE, then we're following the area's
    ;; exit trail (forwards, since we never follow the exit trail backwards).
    ld a, e
    if_eq EXIT_NODE, jr, _AreaMapFollowTrail_CopyExitTrail
    ;; Otherwise, make hl point to the trail node's trail array.
    ld c, e  ; param: node index
    call Func_GetPointerToNode_hl  ; preserves de
    ld bc, NODE_Trail_u8_arr
    add hl, bc
    ;; Node trails start at that node and proceed towards the previous node.
    ;; So if the destination node is the same as the trail node, that means
    ;; we're following a node's trail back to itself, so we need to reverse the
    ;; trail.
    ld a, d
    if_eq e, jr, _AreaMapFollowTrail_CopyTrailReverse
    jr _AreaMapFollowTrail_CopyTrailForward
_AreaMapFollowTrail_CopyExitTrail:
    romb BANK("AreaData")
    ld hl, Ram_AreaMapExitTrail_u8_arr_ptr
    deref hl
_AreaMapFollowTrail_CopyTrailForward:
    ;; At this point, hl points to a trail array to copy as-is.
    ldw de, hl                             ; param: src
    ld hl, Ram_AreaMapWalkingTrail_u8_arr  ; param: dest
    ld bc, MAX_TRAIL_LENGTH                ; param: count
    call Func_MemCopy
    jr _AreaMapFollowTrail_StartFollowing
_AreaMapFollowTrail_CopyTrailReverse:
    ;; At this point, hl points to a trail array to copy.  Put the length of
    ;; the trail in c and make hl point to the last trail entry.
    ld c, 0
    .lenLoop
    inc c
    ld a, [hl+]
    bit TRAILB_END, a
    jr z, .lenLoop
    dec hl
    ;; Copy the trail array, in reserve order, with directions reversed, and
    ;; with the TRAILB_END flags fixed.
    ld de, Ram_AreaMapWalkingTrail_u8_arr
    .revLoop
    ld a, [hl-]
    xor TRAIL_DIR_MASK
    dec c
    jr z, .finishRev
    res TRAILB_END, a
    ld [de], a
    inc de
    jr .revLoop
    .finishRev
    set TRAILB_END, a
    ld [de], a
_AreaMapFollowTrail_StartFollowing:
    xor a
    ld [Ram_AreaMapWalkingIndex_u8], a
    ld hl, Ram_AreaMapWalkingTrail_u8_arr
_AreaMapFollowTrail_StartTrailTick:
    ;; At this point, hl points to the next entry in the trail array.  Start
    ;; moving the avatar along that entry.
    ld e, [hl]  ; param: trail entry
    call Func_AreaMapAvatarApplyTrailEntry
_AreaMapFollowTrail_RunLoop:
    call Func_UpdateAudio
    call Func_UpdateAreaMapAvatarObj
    call Func_WaitForVBlankAndPerformDma
    call Func_ClearAreaMapNodeTitle
    call Func_AnimateAreaMapTiles
    ld a, [Ram_AreaMapAvatarOffset_u8]
    dec a
    ld [Ram_AreaMapAvatarOffset_u8], a
    jr nz, _AreaMapFollowTrail_RunLoop
_AreaMapFollowTrail_EndTrailTick:
    ;; Increment the trail index, and set bc to the old index value.
    ld hl, Ram_AreaMapWalkingIndex_u8
    ldb bc, [hl]
    inc [hl]
    ;; Make hl point to the trail entry we just finished.
    ld hl, Ram_AreaMapWalkingTrail_u8_arr
    add hl, bc
    ;; Copy the trail entry we just finished into a, and also increment hl to
    ;; point to the next trail entry (in case we need to jump back to
    ;; _AreaMapFollowTrail_StartTrailTick).
    ld a, [hl+]
    ;; If we just finished the last entry in the trail, then we're done;
    ;; otherwise, start the next entry (which hl already points to).
    bit TRAILB_END, a
    jr z, _AreaMapFollowTrail_StartTrailTick
_AreaMapFollowTrail_FinishFollowing:
    ld a, [Ram_AreaMapWalkingDestinationNode_u8]
    if_eq EXIT_NODE, jp, Main_AreaMapBackToWorldMap
    ld [Ram_AreaMapCurrentNode_u8], a
    call Func_PlaceAvatarAtCurrentNode
    jp Main_AreaMapCommand

;;;=========================================================================;;;

;;; Fades out the LCD and returns to the world map screen.
Main_AreaMapBackToWorldMap:
    call Func_ClearOam
    call Func_FadeOut
    ld a, [Ram_AreaMapCurrentArea_u8]
    ld c, a  ; param: area number
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
    deref hl
    add hl, bc
    ;; Switch to the ROM bank that holds the NODE struct.
    romb BANK("AreaData")
    ret

;;;=========================================================================;;;

;;; Writes a row of spaces to VRAM on the bottom BG tile row of the screen.
Func_ClearAreaMapNodeTitle:
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

;;;=========================================================================;;;

;;; Sets Ram_AreaMapAvatarRow_u8 and Ram_AreaMapAvatarCol_i8 to the row/col of
;;; the current node, and writes the current node's title to VRAM on the bottom
;;; BG tile row of the screen.
Func_PlaceAvatarAtCurrentNode:
    call Func_GetPointerToCurrentNode_hl
    ;; Set the avatar's row/col/offset.
    ASSERT NODE_Row_u8 == 0
    ld a, [hl+]
    ld [Ram_AreaMapAvatarRow_u8], a
    ASSERT NODE_Col_u8 == 1
    ld a, [hl]
    ld [Ram_AreaMapAvatarCol_i8], a
    xor a
    ld [Ram_AreaMapAvatarOffset_u8], a
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

;;; Updates the avatar's row, col, facing direction, and offset to begin
;;; walking along a trail entry from its current position.
;;; @param e The trail entry to apply.
;;; @preserve e, hl
Func_AreaMapAvatarApplyTrailEntry:
    ;; Set d to the trail entry's direction, and set the avatar's facing
    ;; direction to match.
    ld a, e
    and TRAIL_DIR_MASK
    ld d, a
    ld [Ram_AreaMapAvatarFacing_u8], a
    ;; Set c to the trail entry's tile distance, and set the avatar's pixel
    ;; offset to 8 times that distance.
    ld a, e
    and TRAIL_DIST_MASK
    ld c, a
    swap a
    rrca
    ld [Ram_AreaMapAvatarOffset_u8], a
    ;; Update the avatar's row/col based on the direction and distance.
    ld a, d
    if_eq TRAIL_EAST, jr, .east
    if_eq TRAIL_NORTH, jr, .north
    if_eq TRAIL_SOUTH, jr, .south
    .west
    xor a
    sub c
    ld c, a
    .east
    ld a, [Ram_AreaMapAvatarCol_i8]
    add c
    ld [Ram_AreaMapAvatarCol_i8], a
    ret
    .north
    xor a
    sub c
    ld c, a
    .south
    ld a, [Ram_AreaMapAvatarRow_u8]
    add c
    ld [Ram_AreaMapAvatarRow_u8], a
    ret

;;; Updates the shadow OAMA struct for the area map avatar.
Func_UpdateAreaMapAvatarObj:
    ;; Based on the direction the avatar is facing, store flags in b, base tile
    ;; ID in c, Y-offset in d, and X-offset in e.
    ld b, AVATAR_PALETTE
    ld a, [Ram_AreaMapAvatarOffset_u8]
    ld d, a
    ld a, [Ram_AreaMapAvatarFacing_u8]
    if_eq TRAIL_SOUTH, jr, .southFacing
    if_eq TRAIL_NORTH, jr, .northFacing
    ld c, AVATAR_W1_TILEID
    if_eq TRAIL_WEST, jr, .westFacing
    .eastFacing
    ld b, AVATAR_PALETTE | OAMF_XFLIP
    ld e, d
    ld d, 0
    jr .doneFacing
    .westFacing
    xor a
    sub d
    ld e, a
    ld d, 0
    jr .doneFacing
    .southFacing
    ld c, AVATAR_S1_TILEID
    jr .vertFacing
    .northFacing
    ld c, AVATAR_N1_TILEID
    xor a
    sub d
    ld d, a
    .vertFacing
    ld e, 0
    .doneFacing
    ;; Set Y position:
    ld a, [Ram_AreaMapAvatarRow_u8]
    swap a
    rrca
    add 13
    sub d
    ld [Ram_ElephantL_oama + OAMA_Y], a
    ;; Set X position:
    ld a, [Ram_AreaMapAvatarCol_i8]
    and %00011111  ; account for possibility that col is negative
    swap a
    rrca
    add 7
    sub e
    ld [Ram_ElephantL_oama + OAMA_X], a
    ;; Set tile ID:
    ld a, [Ram_AreaMapAnimationClock_u8]
    and %00010000
    swap a
    add c
    ld [Ram_ElephantL_oama + OAMA_TILEID], a
    ;; Set flags:
    ld a, b
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
    ;; fall through to Func_DrawTrail

;;; Draws the trail tick marks for a node trail or area exit trail.
;;; @prereq ROM bank is set to BANK("AreaData").
;;; @param de A pointer to the trail array.
;;; @param hl A pointer to BG map byte in VRAM for the start of the trail.
Func_DrawTrail:
    .trailLoop
    ;; If this is the last entry in the trail, we're done.  (We don't draw a
    ;; trail tick mark for the last trail entry, since in general it would be
    ;; on top of another node, or off the map).
    ld a, [de]
    bit TRAILB_END, a
    ret nz
    ;; Extract the direction from the trail entry, and set bc to the byte
    ;; offset in VRAM for one step in that direction.
    and TRAIL_DIR_MASK
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
    and TRAIL_DIST_MASK
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
