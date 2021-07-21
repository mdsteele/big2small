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
INCLUDE "src/charmap.inc"
INCLUDE "src/color.inc"
INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"
INCLUDE "src/save.inc"
INCLUDE "src/tileset.inc"
INCLUDE "src/worldmap.inc"
INCLUDE "src/vram.inc"

;;;=========================================================================;;;

ARROW_PALETTE  EQU (OAMF_PAL1 | 0)
AVATAR_PALETTE EQU (OAMF_PAL0 | 1)

ARROW_NS_TILEID EQU $48
ARROW_EW_TILEID EQU $4c
AVATAR_INITIAL_TILEID EQU $68

RSRESET
PSFX_Channel_u8 RB 1
PSFX_RomBank_u8 RB 1
PSFX_SfxPtr_ptr RW 1
sizeof_PSFX     RB 0

D_PSFX: MACRO
    STATIC_ASSERT _NARG == 2
    STATIC_ASSERT (\2) == 1 || (\2) == 4
    DB (\2), BANK(\1), LOW(\1), HIGH(\1)
ENDM

;;;=========================================================================;;;

SECTION "WorldMapState", WRAM0

;;; The currently selected area (one of the AREA_* enum values).
Ram_WorldMapCurrentArea_u8:
    DB

;;; The furthest area that's currently unlocked (one of the AREA* enum values).
Ram_WorldMapLastUnlockedArea_u8:
    DB

;;; The pixel X and Y coordinates for the avatar on the 256x256 world tile map.
Ram_WorldMapAvatarX_u8:
    DB
Ram_WorldMapAvatarY_u8:
    DB

;;; The X and Y background scroll coordinates to be copied into rSCX and rSCY
;;; during the next VBlank period.
Ram_WorldMapNextScrollX_u8:
    DB
Ram_WorldMapNextScrollY_u8:
    DB

;;; The area we're currently walking towards (one of the AREA_* enum values).
Ram_WorldMapDestinationArea_u8:
    DB

;;; The avatar's signed X and Y speed (in pixels per frame) while walking.
Ram_WorldMapWalkSpeedX_i8:
    DB
Ram_WorldMapWalkSpeedY_i8:
    DB

;;; The number of steps to take before reading the next path opcode.
Ram_WorldMapWalkStepCounter_u8:
    DB

;;;=========================================================================;;;

SECTION "WorldMapFunctions", ROM0

;;; @prereq LCD is off.
;;; @param c The current area (one of the AREA_* enum values).
Func_WorldMapLoad:
    push bc
    ;; Set up avatar object.
    call Func_ClearOam
    ld a, AVATAR_INITIAL_TILEID
    ld [Ram_Avatar_oama + OAMA_TILEID], a
    ld a, AVATAR_PALETTE
    ld [Ram_Avatar_oama + OAMA_FLAGS], a
    ;; Set up arrow objects.
    ld a, ARROW_PALETTE
    ld [Ram_ArrowN_oama + OAMA_FLAGS], a
    ld [Ram_ArrowE_oama + OAMA_FLAGS], a
    ld a, ARROW_PALETTE | OAMF_XFLIP
    ld [Ram_ArrowW_oama + OAMA_FLAGS], a
    ld a, ARROW_PALETTE | OAMF_YFLIP
    ld [Ram_ArrowS_oama + OAMA_FLAGS], a
    ld a, ARROW_NS_TILEID
    ld [Ram_ArrowN_oama + OAMA_TILEID], a
    ld [Ram_ArrowS_oama + OAMA_TILEID], a
    ld a, ARROW_EW_TILEID
    ld [Ram_ArrowE_oama + OAMA_TILEID], a
    ld [Ram_ArrowW_oama + OAMA_TILEID], a
    ;; Initialize state.
    pop bc
    call Func_WorldMapSetCurrentArea
    xor a
    ld [Ram_AnimationClock_u8], a
_WorldMapLoad_LoadTileMap:
    ;; Load the colorset.
    ld c, COLORSET_WORLD  ; param: colorset
    xcall FuncX_Colorset_Load
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
_WorldMapLoad_SetUnlockedAreas:
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
_WorldMapLoad_Finish:
    ;; Initialize music.
    PLAY_SONG DataX_Train_song
    ;; Set up window.
    ld a, 7
    ldh [rWX], a
    ld a, SCRN_Y - 8
    ldh [rWY], a
    ret

;;; @prereq LCD is off.
;;; @param c The current area (one of the AREA_* enum values).
Main_WorldMapResume::
    call Func_WorldMapLoad
    ;; Turn on the LCD and fade in.
    ld d, LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00
    call Func_FadeIn
    ;; fall through to Main_WorldMapCommand

;;; Animates the map while waiting for the player to press a button, then takes
;;; appropriate action.
Main_WorldMapCommand:
    call Func_WorldMapUpdateArrowObjects
    call Func_WorldMapAnimateAvatar
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_AnimateTiles
    call Func_UpdateButtonState
_WorldMapCommand_HandleButtons:
    ldh a, [Hram_ButtonsPressed_u8]
    ld d, a
    and PADF_START | PADF_A
    jr nz, _WorldMapCommand_EnterArea
_WorldMapCommand_HandleDpad:
    ;; Check if the D-pad was pressed.
    ld a, d
    and PADF_UP | PADF_DOWN | PADF_LEFT | PADF_RIGHT
    jr z, Main_WorldMapCommand
    ;; Get location data for the current area.
    ld d, a
    ld a, [Ram_WorldMapCurrentArea_u8]
    ld c, a  ; param: area number
    xcall FuncX_LocationData_Get_hl  ; preserves d
    ;; If the player pressed the D-pad direction for the previous location,
    ;; follow the path to go there.
    ld bc, LOCA_PrevDir_u8
    add hl, bc
    ld a, [hl+]
    if_ne d, jr, .notPrev
    ASSERT LOCA_PrevPath_path_ptr == 1 + 1 + LOCA_PrevDir_u8
    inc hl
    ld e, -1
    jr _WorldMapCommand_FollowPath
    .notPrev
    ;; Check if we're able to go to the next area.
    ld a, [Ram_WorldMapLastUnlockedArea_u8]
    ld c, a
    ld a, [Ram_WorldMapCurrentArea_u8]
    if_eq c, jr, .notNext
    ;; If the player pressed the D-pad direction for the next location,
    ;; follow the path to go there.
    ASSERT LOCA_NextDir_u8 == 1 + LOCA_PrevDir_u8
    ld a, [hl+]
    if_ne d, jr, .notNext
    ASSERT LOCA_NextPath_path_ptr == 1 + 2 + LOCA_NextDir_u8
    inc hl
    inc hl
    ld e, 1
    jr _WorldMapCommand_FollowPath
    .notNext
_WorldMapCommand_CannotMove:
    PLAY_SFX1 DataX_CannotMove_sfx1
    jr Main_WorldMapCommand

_WorldMapCommand_FollowPath:
    ;; At this point, e is the area number offset (-1 for prev or 1 for next),
    ;; and hl points to the path pointer.  First, hide the area title.
    ldh a, [rLCDC]
    and ~LCDCF_WINON
    ldh [rLCDC], a
    ;; Hide the arrow objects.
    xor a
    ld [Ram_ArrowN_oama + OAMA_Y], a
    ld [Ram_ArrowS_oama + OAMA_Y], a
    ld [Ram_ArrowE_oama + OAMA_Y], a
    ld [Ram_ArrowW_oama + OAMA_Y], a
    ;; Start the walking animation.
    deref hl  ; param: pointer to PATH struct
    jp Main_WorldMapWalk

_WorldMapCommand_EnterArea:
    call Func_FadeOut
    ld a, [Ram_WorldMapCurrentArea_u8]
    ld c, a  ; param: area number
    jp Main_AreaMapEnter

;;;=========================================================================;;;

;;; @prereq LCD is off.
Main_WorldMapNewGame::
    ld c, AREA_FOREST  ; param: current area
    call Func_WorldMapLoad
    ;; Position the avatar.
    ld a, 52
    ld [Ram_WorldMapAvatarX_u8], a
    ld a, 231
    ld [Ram_WorldMapAvatarY_u8], a
    call Func_WorldMapUpdateAvatarAndNextScroll
    ld a, [Ram_WorldMapNextScrollX_u8]
    ldh [rSCX], a
    ld a, [Ram_WorldMapNextScrollY_u8]
    ldh [rSCY], a
    ;; Fade in and follow the initial path.
    ld d, LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WIN9C00
    call Func_FadeIn
    ld e, 0  ; param: area number delta
    ld hl, DataX_LocationData_NewGame_path  ; param: pointer to PATH struct
    ;; fall through to Main_WorldMapWalk

;;; Mode for making the avatar follow a path between locations on the world
;;; map.
;;; @param e Area number delta (-1 for prev or 1 for next).
;;; @param hl Pointer to a PATH struct in BANK("LocationData").
Main_WorldMapWalk:
    ;; Store the destination area number for later.
    ld a, [Ram_WorldMapCurrentArea_u8]
    add e
    ld [Ram_WorldMapDestinationArea_u8], a
    ;; Initialize state.
    xor a
    ld [Ram_WorldMapWalkSpeedX_i8], a
    ld [Ram_WorldMapWalkSpeedY_i8], a
    inc a
    ld [Ram_WorldMapWalkStepCounter_u8], a
_WorldMapWalk_Frame:
    push hl
    call Func_UpdateAudio
    call Func_WorldMapUpdateAvatarAndNextScroll
    call Func_WaitForVBlankAndPerformDma
    call Func_AnimateTiles
    ;; Update screen scroll position.
    ld a, [Ram_WorldMapNextScrollX_u8]
    ldh [rSCX], a
    ld a, [Ram_WorldMapNextScrollY_u8]
    ldh [rSCY], a
    ;; Check if there are more steps to take before reading the next opcode.
    ld hl, Ram_WorldMapWalkStepCounter_u8
    dec [hl]
    pop hl
    jr nz, _WorldMapWalk_TakeStep
_WorldMapWalk_Read:
    romb BANK("LocationData")
    ld a, [hl+]
    bit 7, a
    jr nz, _WorldMapWalk_ObjOrSound
    bit 6, a
    jr z, _WorldMapWalk_RepeatOrHalt
_WorldMapWalk_SetSpeed:
    ;; At this point, a holds %01xxxyyy.  We need to decode xxx and yyy as
    ;; signed 3-bit numbers.
    ld b, a
    and %00000111
    bit 2, a
    jr z, .nonnegY
    or %11111000
    .nonnegY
    ld [Ram_WorldMapWalkSpeedY_i8], a
    ld a, b
    and %00111000
    rlca
    swap a
    bit 2, a
    jr z, .nonnegX
    or %11111000
    .nonnegX
    ld [Ram_WorldMapWalkSpeedX_i8], a
    ;; Take a single step.
    ld a, 1
    ld [Ram_WorldMapWalkStepCounter_u8], a
_WorldMapWalk_TakeStep:
    ;; Update X position.
    ld a, [Ram_WorldMapWalkSpeedX_i8]
    ld b, a
    ld a, [Ram_WorldMapAvatarX_u8]
    add b
    ld [Ram_WorldMapAvatarX_u8], a
    ;; Update Y position.
    ld a, [Ram_WorldMapWalkSpeedY_i8]
    ld b, a
    ld a, [Ram_WorldMapAvatarY_u8]
    add b
    ld [Ram_WorldMapAvatarY_u8], a
    jr _WorldMapWalk_Frame

_WorldMapWalk_ObjOrSound:
    bit 6, a
    jr nz, _WorldMapWalk_Sound
_WorldMapWalk_Obj:
    ;; At this point, a holds %10uftttt.  We need to use %u and %f to set the
    ;; avatar's object flags, and use %tttt to pick a tile ID.
    ld b, a
    ld a, AVATAR_PALETTE
    bit POBJB_UNDER, b
    jr z, .notUnder
    set OAMB_PRI, a
    .notUnder
    bit POBJB_FLIP, b
    jr z, .notFlipped
    set OAMB_XFLIP, a
    .notFlipped
    ld [Ram_Avatar_oama + OAMA_FLAGS], a
    ld a, b
    and %00001111
    mult 4
    add AVATAR_INITIAL_TILEID
    ld [Ram_Avatar_oama + OAMA_TILEID], a
    jr _WorldMapWalk_Read
_WorldMapWalk_Sound:
    ;; At this point, a holds %11ssssss.
    push hl
    ;; Make hl point to entry number %ssssss in Data_WorldMapSounds_psfx_arr.
    and %00111111
    mult sizeof_PSFX
    ldb bc, a
    ld hl, Data_WorldMapSounds_psfx_arr
    add hl, bc
    ;; Store the channel number in e.
    ASSERT PSFX_Channel_u8 == 0
    ld a, [hl+]
    ld e, a
    ;; Read the ROM bank into c.
    ASSERT PSFX_RomBank_u8 == 1
    ld a, [hl+]
    ld c, a
    ;; Read the pointer into hl.
    ASSERT PSFX_SfxPtr_ptr == 2
    deref hl
    ;; Play the sound on the correct channel.
    bit 2, e
    jr nz, .channel4
    .channel1
    call Func_PlaySfx1
    jr .done
    .channel4
    call Func_PlaySfx4
    ;; Proceed to the next opcode.
    .done
    pop hl
    jp _WorldMapWalk_Read

_WorldMapWalk_RepeatOrHalt:
    or a
    jr z, _WorldMapWalk_Halt
    ld [Ram_WorldMapWalkStepCounter_u8], a
    jr _WorldMapWalk_TakeStep

_WorldMapWalk_Halt:
    ld a, [Ram_WorldMapDestinationArea_u8]
    ld c, a  ; param: area number
    call Func_WorldMapSetCurrentArea
    ;; Show the area title.
    ldh a, [rLCDC]
    or LCDCF_WINON
    ldh [rLCDC], a
    jp Main_WorldMapCommand

;;;=========================================================================;;;

Data_WorldMapSounds_psfx_arr:
    .begin
    ASSERT @ - .begin == sizeof_PSFX * PSFX_JUMP
    D_PSFX DataX_Leap_sfx1, 1
    ASSERT @ - .begin == sizeof_PSFX * PSFX_LAUNCH
    D_PSFX DataX_PushPipe_sfx4, 4  ; TODO
    ASSERT @ - .begin == sizeof_PSFX * PSFX_PIPE
    D_PSFX DataX_EnterPipe_sfx1, 1
    ASSERT @ - .begin == sizeof_PSFX * NUM_PSFXS

;;;=========================================================================;;;

;;; Reads Ram_WorldMapAvatar?_u8 and uses it to update the avatar object as
;;; well as Ram_WorldMapNextScroll?_u8.
Func_WorldMapUpdateAvatarAndNextScroll:
    call Func_WorldMapAnimateAvatar
_WorldMapUpdateAvatarAndNextScroll_X:
    ld a, [Ram_WorldMapAvatarX_u8]
    ld b, a
    ;; Compute next value for rSCX.
    if_ge SCRN_X / 2 - 8, jr, .notLow
    ld a, -8
    jr .setPos
    .notLow
    if_lt SCRN_VX - SCRN_X / 2 + 8, jr, .notHigh
    ld a, SCRN_VX - SCRN_X + 8
    jr .setPos
    .notHigh
    sub SCRN_X / 2
    .setPos
    ld [Ram_WorldMapNextScrollX_u8], a
    ;; Set X-position for avatar object.
    ld c, a
    ld a, b
    sub c
    add 4
    ld [Ram_Avatar_oama + OAMA_X], a
_WorldMapUpdateAvatarAndNextScroll_Y:
    ld a, [Ram_WorldMapAvatarY_u8]
    ld b, a
    ;; Compute next value for rSCY.
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
    ld [Ram_WorldMapNextScrollY_u8], a
    ;; Set Y-position for avatar object.
    ld c, a
    ld a, b
    sub c
    ld [Ram_Avatar_oama + OAMA_Y], a
    ret

;;; Switches the parity of the avatar object's tile ID every few frames
;;; (alternating between 2n and 2n+1).
Func_WorldMapAnimateAvatar:
    ld a, [Ram_AnimationClock_u8]
    and %00010000
    swap a
    rlca
    ld b, a
    ld a, [Ram_Avatar_oama + OAMA_TILEID]
    and %11111100
    or b
    ld [Ram_Avatar_oama + OAMA_TILEID], a
    ret

;;; Updates the X/Y positions of the arrow objects.
Func_WorldMapUpdateArrowObjects:
    ;; Blink the arrows by forcing d (the set of arrows to display) to zero
    ;; for half of all frames.
    ld d, 0
    ld a, [Ram_AnimationClock_u8]
    and %00010000
    jr z, .updateArrows
    ;; Set c to the current area number (it will be used as a parameter for
    ;; FuncX_LocationData_Get_hl below).
    ld a, [Ram_WorldMapCurrentArea_u8]
    ld c, a
    ;; Set b to 1 if we're able to go to the next area, 0 otherwise.
    ld b, 0
    ld a, [Ram_WorldMapLastUnlockedArea_u8]
    if_eq c, jr, .cannotNext
    ld b, 1
    .cannotNext
    ;; Store the D-pad directions that the avatar can move in d.
    push bc
    xcall FuncX_LocationData_Get_hl
    pop bc
    inc hl
    inc hl
    ASSERT LOCA_PrevDir_u8 == 2
    ld a, [hl+]
    bit 0, b
    jr z, .skipNextDir
    ASSERT LOCA_NextDir_u8 == 3
    or [hl]
    .skipNextDir
    ld d, a
    ;; Store the avatar object's left in c and top in b.
    ld a, [Ram_Avatar_oama + OAMA_X]
    ld [Ram_ArrowN_oama + OAMA_X], a
    ld [Ram_ArrowS_oama + OAMA_X], a
    ld c, a
    ld a, [Ram_Avatar_oama + OAMA_Y]
    ld b, a
    .updateArrows
_WorldMapUpdateArrowObjects_North:
    xor a
    bit PADB_UP, d
    jr z, .noMove
    ld a, b
    sub 12
    .noMove
    ld [Ram_ArrowN_oama + OAMA_Y], a
_WorldMapUpdateArrowObjects_South:
    xor a
    bit PADB_DOWN, d
    jr z, .noMove
    ld a, b
    add 20
    .noMove
    ld [Ram_ArrowS_oama + OAMA_Y], a
_WorldMapUpdateArrowObjects_East:
    xor a
    bit PADB_RIGHT, d
    jr z, .noMove
    ld a, c
    add 12
    ld [Ram_ArrowE_oama + OAMA_X], a
    ld a, b
    add 4
    .noMove
    ld [Ram_ArrowE_oama + OAMA_Y], a
_WorldMapUpdateArrowObjects_West:
    xor a
    bit PADB_LEFT, d
    jr z, .noMove
    ld a, c
    sub 12
    ld [Ram_ArrowW_oama + OAMA_X], a
    ld a, b
    add 4
    .noMove
    ld [Ram_ArrowW_oama + OAMA_Y], a
    ret

;;; Makes the specified area the currently selected area for the world map, and
;;; puts that area's title on the screen.
;;; @prereq LCD is off, or VBlank has recently started.
;;; @param c The area to make current (one of the AREA_* enum values).
Func_WorldMapSetCurrentArea:
    ;; Set the current area.
    ld a, c
    ld [Ram_WorldMapCurrentArea_u8], a
_WorldMapSetCurrentArea_DrawTitle:
    ;; Make hl point to the title of area c.
    call Func_GetAreaData_hl
    romb BANK("AreaData")
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
_WorldMapSetCurrentArea_DrawStars:
    ;; If the area is 100% completed, draw stars around its title.
    ld a, [Ram_WorldMapCurrentArea_u8]
    ASSERT LOW(Ram_ProgressAreas_u8_arr) + NUM_AREAS < $100
    add LOW(Ram_ProgressAreas_u8_arr)
    ld l, a
    ld h, HIGH(Ram_ProgressAreas_u8_arr)
    bit STATB_MADE_PAR, [hl]
    jr z, .noStars
    ld a, "*"
    ld [Vram_WindowMap + 1], a
    ld [Vram_WindowMap + SCRN_X_B - 2], a
    .noStars
_WorldMapSetCurrentArea_SetAvatarPosition:
    ld a, [Ram_WorldMapCurrentArea_u8]
    ld c, a
    xcall FuncX_LocationData_Get_hl
    ASSERT LOCA_PixelX_u8 == 0
    ld a, [hl+]
    ld [Ram_WorldMapAvatarX_u8], a
    ASSERT LOCA_PixelY_u8 == 1
    ld a, [hl]
    ld [Ram_WorldMapAvatarY_u8], a
    call Func_WorldMapUpdateAvatarAndNextScroll
_WorldMapSetCurrentArea_ScrollMap:
    ld a, [Ram_WorldMapNextScrollX_u8]
    ldh [rSCX], a
    ld a, [Ram_WorldMapNextScrollY_u8]
    ldh [rSCY], a
    ret

;;;=========================================================================;;;
