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

;;; The grayscale palette used for rOBP0 and rBGP.
GRAYSCALE_PALETTE_0 EQU %11100100
;;; The grayscale palette used for rOBP1.
GRAYSCALE_PALETTE_1 EQU %11010000

;;; The grayscale palette at 2/3 and 1/3 saturation (used for rBGP, rOBP0, and
;;; rOBP1 while fading the screen).
GRAYSCALE_PALETTE_23 EQU %10010000
GRAYSCALE_PALETTE_13 EQU %01000000

;;;=========================================================================;;;

;;; The width and height of a VRAM tile, in pixels.
TILE_WIDTH  EQU 8
TILE_HEIGHT EQU 8

;;;=========================================================================;;;

;;; TILE: Data for a single VRAM tile.
RSRESET
sizeof_TILE EQU 16

;;;=========================================================================;;;
