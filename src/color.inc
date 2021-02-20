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

;; Enum values for FuncX_SetBgColorPalettes:
COLORSET_SPRING EQU 0
COLORSET_SUMMER EQU 1
COLORSET_AUTUMN EQU 2
COLORSET_WINTER EQU 3
COLORSET_SPACE  EQU 4

;;; The number of BG/obj color palettes.
NUM_BG_CPAL  EQU 8
NUM_OBJ_CPAL EQU 8

;;;=========================================================================;;;

;;; CPAL: Data for a single color palette.
RSRESET
CPAL_Color0_u16 RW 1
CPAL_Color1_u16 RW 1
CPAL_Color2_u16 RW 1
CPAL_Color3_u16 RW 1
sizeof_CPAL RB 0

;;;=========================================================================;;;
