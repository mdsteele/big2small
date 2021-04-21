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
;;; Music: A banked pointer to the SONG struct to play during this puzzle.
PUZZ_Music_song_bptr   EQU (TERRAIN_COLS + 16 * 3)
;;; Intro: A banked pointer to the DLOG struct for the intro dialog.
PUZZ_Intro_dlog_bptr   EQU (TERRAIN_COLS + 16 * 4)
;;; Outro: A banked pointer to the DLOG struct for the outro dialog.
PUZZ_Outro_dlog_bptr   EQU (TERRAIN_COLS + 16 * 5)
;;; Tileset: A TILESET_* enum value indicating which tileset this puzzle uses.
PUZZ_Tileset_u8        EQU (TERRAIN_COLS + 16 * 6 + 0)
;;; Colorset: A COLORSET_* enum value indicating which set of background color
;;;   palettes this puzzle uses.
PUZZ_Colorset_u8       EQU (TERRAIN_COLS + 16 * 6 + 1)
;;; Par: If the player solves the puzzle in this many moves or fewer, it counts
;;;   as making par.
PUZZ_Par_bcd16         EQU (TERRAIN_COLS + 16 * 7 + 0)
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
O_CE3 RB 1  ; Cliff east multi
O_CW3 RB 1  ; Cliff west multi

;;; Goal terrain:
G_PNT RB 1  ; Peanut
G_APL RB 1  ; Apple
G_CHS RB 1  ; Cheese

;; Special terrain:
S_MIN RB 0  ; Terrain types less than S_MIN have no terrain action.
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
S_TME RB 1  ; Teleporter for mouse (index E)
S_TMF RB 1  ; Teleporter for mouse (index F)

;;; Water terrain:
R_MIN RB 0  ; Terrain types from R_MIN to M_MIN are water.
R_RNS RB 1  ; River north/south
R_REW RB 1  ; River east/west
R_RNE RB 1  ; River north/east
R_RNW RB 1  ; River north/west
R_RSE RB 1  ; River south/east
R_RSW RB 1  ; River south/west
R_RS1 RB 1  ; River south single
R_SNN RB 1  ; Shoreline on north
R_SNE RB 1  ; Shoreline on north/east
R_SNW RB 1  ; Shoreline on north/west
R_ONN RB 1  ; Ocean with shore in northern corners
R_ONE RB 1  ; Ocean with shore in northeast corner
R_ONW RB 1  ; Ocean with shore in northwest corner
R_OOP RB 1  ; Open ocean
R_EDG RB 1  ; Edge of sewer platform
R_GRT RB 1  ; Sewer grating
R_GDR RB 1  ; Space girder

;;; Mousehole terrain:
M_MIN RB 0  ; Terrain types from M_MIN to W_MIN are mouseholes.
M_RNA RB 1  ; Ramp narrow
M_UNDER_MIN RB 0
M_FNS RB 1  ; North/south mousehole through fence
M_BNS RB 1  ; North/south mousehole through brick wall
M_UNDER_END RB 0

;;; Wall terrain:
W_MIN RB 0  ; Terrain types from W_MIN on up are walls.
W_RCK RB 1  ; Rock
W_COW RB 1  ; Cow
W_DMP RB 1  ; Dumpster
W_FE1 RB 1  ; Fence east end
W_FE3 RB 1  ; Fence east with westward split
W_FW1 RB 1  ; Fence west end
W_FW3 RB 1  ; Fence west with eastward split
W_FNS RB 1  ; Fence north/south
W_FNE RB 1  ; Fence north/east
W_FNW RB 1  ; Fence north/west
W_FSE RB 1  ; Fence south/east
W_FSW RB 1  ; Fence south/west
W_FEW RB 1  ; Fence east/west
W_HNE RB 1  ; House northeast
W_HNW RB 1  ; House northwest
W_HSE RB 1  ; House southeast
W_HSW RB 1  ; House southwest
W_TTP RB 1  ; Tree top
W_TTR RB 1  ; Tree trunk
W_TST RB 1  ; Trees stacked
W_CS1 RB 1  ; Cliff south single
W_CS3 RB 1  ; Cliff south multi
W_CSE RB 1  ; Cliff south/east
W_CSW RB 1  ; Cliff south/west
W_CEW RB 1  ; Cliff east/west
W_CE1 RB 1  ; Cliff east single
W_CE3 RB 1  ; Cliff east multi
W_CW1 RB 1  ; Cliff west single
W_CW3 RB 1  ; Cliff west multi
W_BS1 RB 1  ; Brick wall south single
W_BS3 RB 1  ; Brick wall south multi
W_BSE RB 1  ; Brick wall south/east
W_BSW RB 1  ; Brick wall south/west
W_BE1 RB 1  ; Brick wall east single
W_BW1 RB 1  ; Brick wall west single
W_LNS RB 1  ; Brick lip north/south
W_LN1 RB 1  ; Brick lip north single
W_LN3 RB 1  ; Brick lip north multi
W_LNE RB 1  ; Brick lip north/east
W_LNW RB 1  ; Brick lip north/west
W_LS1 RB 1  ; Brick lip south single
W_LS3 RB 1  ; Brick lip south multi
W_LSE RB 1  ; Brick lip south/east
W_LSW RB 1  ; Brick lip south/west
W_LEW RB 1  ; Brick lip east/west
W_LE1 RB 1  ; Brick lip east single
W_LE3 RB 1  ; Brick lip east multi
W_LW1 RB 1  ; Brick lip west single
W_LW3 RB 1  ; Brick lip west multi
W_LLE RB 1  ; Brick lip L-shape east
W_LC4 RB 1  ; Brick lip four sides
W_ROP RB 1  ; Brick roof open

;;;=========================================================================;;;
