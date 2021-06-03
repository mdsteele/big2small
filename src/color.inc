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

NUM_COLORS_PER_CPAL EQU 4
NUM_CPALS_PER_CSET EQU 8

;;;=========================================================================;;;

;; Enum values for FuncX_Colorset_Load:
RSRESET
COLORSET_SPRING RB 1
COLORSET_SUMMER RB 1
COLORSET_AUTUMN RB 1
COLORSET_WINTER RB 1
COLORSET_SEWER  RB 1
COLORSET_SPACE  RB 1

;;;=========================================================================;;;

;;; CPAL: Data for a single color palette.
RSRESET
STATIC_ASSERT NUM_COLORS_PER_CPAL == 4
CPAL_Colors_u16_arr4 RW 4
sizeof_CPAL RB 0

;;;=========================================================================;;;

;;; CSET: Data for a full colorset.
RSRESET
STATIC_ASSERT NUM_CPALS_PER_CSET == 8
CSET_Palettes_cpal_arr8 RB 8 * sizeof_CPAL
sizeof_CSET RB 0

;;;=========================================================================;;;
