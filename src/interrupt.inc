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

;;; HLCD: Describes one entry in the STAT interrupt table, giving instructions
;;;   for LCD settings to change during HBlank between particular lines.
RSRESET
;;; Lcdc: The value that should be stored to rLCDC when this table entry fires.
;;;   The value MUST include LCDCF_ON.
HLCD_Lcdc_u8    RB 1
;;; Scy: The value that should be stored to rSCY when this table entry fires.
HLCD_Scy_u8     RB 1
;;; NextLyc: The value that should be stored to rLYC when this table entry
;;;   fires; this specifies the screen line on which to fire the next entry in
;;;   the table.  If this is the last entry in the table, this field should be
;;;   set to 255.
HLCD_NextLyc_u8 RB 1
sizeof_HLCD     RB 0

;;;=========================================================================;;;
