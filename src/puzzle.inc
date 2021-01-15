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

;;; The dimensions of a puzzle's terrain grid:
TERRAIN_COLS EQU 10
TERRAIN_ROWS EQU 9

;;; Bit indices for ANIM_MoveDirs_u8:
DIRB_NORTH EQU 3
DIRB_SOUTH EQU 2
DIRB_EAST  EQU 1
DIRB_WEST  EQU 0

;;; Flags for ANIM_MoveDirs_u8, and enum values for ANIM_Facing_u8:
DIRF_NORTH EQU (1 << DIRB_NORTH)
DIRF_SOUTH EQU (1 << DIRB_SOUTH)
DIRF_EAST  EQU (1 << DIRB_EAST)
DIRF_WEST  EQU (1 << DIRB_WEST)

;;; Enum values for Ram_SelectedAnimal_u8:
ANIMAL_ELEPHANT EQU 0
ANIMAL_GOAT     EQU 1
ANIMAL_MOUSE    EQU 2

;;;=========================================================================;;;

;;; ANIM: Describes an animal character.
RSRESET
;;; Position: The animal's current position.  The high nibble gives the Y
;;;   position (0-8) and the low nibble gives the X position (0-9).
ANIM_Position_u8    RB 1
;;; Facing: Which direction the animal is currently facing.  This should be set
;;;   to one of the DIRF_* constants.
ANIM_Facing_u8      RB 1
sizeof_ANIM         RB 0

;;;=========================================================================;;;

;;; PUZZ: Describes a puzzle.  Given a position byte N (with the high nibble
;;;   giving the 0-8 Y position and the low nibble gives the 0-9 X position),
;;;   the Nth byte of the PUZZ struct gives the terrain type at that position.
;;;   Additional metadata for the puzzle is tucked between terrain rows, as
;;;   described below.
RSRESET
;;; Elephant: The starting position and face direction for the elephant.
PUZZ_Elephant_anim     EQU (TERRAIN_COLS + 16 * 0)
;;; Goat: The starting position and face direction for the goat.
PUZZ_Goat_anim         EQU (TERRAIN_COLS + 16 * 1)
;;; Mouse: The starting position and face direction for the mouse.
PUZZ_Mouse_anim        EQU (TERRAIN_COLS + 16 * 2)
;;; Music: A banked pointer to the song struct to play during this puzzle.
PUZZ_Music_song_bptr   EQU (TERRAIN_COLS + 16 * 3)
sizeof_PUZZ            EQU (TERRAIN_COLS + 16 * (TERRAIN_ROWS - 1))

;;;=========================================================================;;;

RSRESET

;;; Open terrain:
O_EMP RB 1  ; Empty
O_GRS RB 1  ; Grass
O_BNS RB 1  ; Bridge over river north/south
O_BEW RB 1  ; Bridge over river east/west
O_RMD RB 1  ; Ramp medium
O_RWL RB 1  ; Ramp wide left
O_RWR RB 1  ; Ramp wide right
O_BST RB 1  ; Bush stump

;;; Goal terrain:
G_PNT RB 1  ; Peanut
G_APL RB 1  ; Apple
G_CHS RB 1  ; Cheese

;; Special terrain:
S_BSH RB 1  ; Bush
S_MTP RB 1  ; Mousetrap
S_PPW RB 1  ; Pipe west
S_PPE RB 1  ; Pipe east
S_ARN RB 1  ; Arrow north
S_ARS RB 1  ; Arrow south
S_ARE RB 1  ; Arrow east
S_ARW RB 1  ; Arrow west
S_TEF RB 1  ; Teleporter for elephant (index F)
S_TGE RB 1  ; Teleporter for goat (index E)
S_TMF RB 1  ; Teleporter for mouse (index F)

;;; River terrain:
R_MIN RB 0  ; Terrain types from R_MIN to M_MIN are rivers.
R_RNS RB 1  ; River north/south
R_REW RB 1  ; River east/west
R_RNE RB 1  ; River north/east
R_RNW RB 1  ; River north/west
R_RSE RB 1  ; River south/east
R_RSW RB 1  ; River south/west

;;; Mousehole terrain:
M_MIN RB 0  ; Terrain types from M_MIN to W_MIN are mouseholes.
M_RNA RB 1  ; Ramp narrow
M_RNS RB 1  ; Rock wall north/south

;;; Wall terrain:
W_MIN RB 0  ; Terrain types from W_MIN on up are walls.
W_RCK RB 1  ; Rock
W_FRT RB 1  ; Fence right
W_FLT RB 1  ; Fence left
W_FMD RB 1  ; Fence middle
W_TTP RB 1  ; Tree top
W_TTR RB 1  ; Tree trunk
W_TST RB 1  ; Trees stacked
W_BLD RB 1  ; Boulder
W_CSO RB 1  ; Cliff face south
W_RNS RB 1  ; Rock wall north/south
W_CRV RB 1  ; Cliff face/rock wall vertical
W_RSO RB 1  ; Rock wall south
W_BN1 RB 1  ; Brick wall north single
W_BN3 RB 1  ; Brick wall north multi
W_BNE RB 1  ; Brick wall north/east
W_BNW RB 1  ; Brick wall north/west
W_BS1 RB 1  ; Brick wall south single
W_BS3 RB 1  ; Brick wall south multi
W_BSE RB 1  ; Brick wall south/east
W_BSW RB 1  ; Brick wall south/west
W_BEW RB 1  ; Brick wall east/west
W_BE3 RB 1  ; Brick wall east multi
W_BW3 RB 1  ; Brick wall west multi
W_BC4 RB 1  ; Brick wall center

;;;=========================================================================;;;
