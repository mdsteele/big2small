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

INCLUDE "src/hardware.inc"
INCLUDE "src/interrupt.inc"
INCLUDE "src/macros.inc"

;;;=========================================================================;;;

SECTION "RstTrampoline", ROM0[$0008]
;;; Calls the function with address hl, then sets the ROM bank before
;;; returning.
;;; @param hl The address to call.
;;; @param a The ROM bank to set before returning.
Rst_Trampoline::
    push af
    rst Rst_CallHl
    pop af
    romb
    ret

SECTION "RstCallHl", ROM0[$0010]
;;; Jumps to the address stored in hl.  Thus, `rst Rst_CallHl` is effectively
;;; `call hl`, if that were a real instruction.
Rst_CallHl::
    jp hl

;;;=========================================================================;;;

SECTION "InterruptVBlank", ROM0[$0040]
    push af
    ld a, 1
    ldh [Hram_VBlank_bool], a
    pop af
    reti

SECTION "InterruptStat", ROM0[$0048]
    push af
    push bc
    ;; Read Hram_StatNext_hlcd_hptr (which must be set to
    ;; LOW(Hram_StatTable_hlcd_arr8) during each VBlank) into c.
    ldh a, [Hram_StatNext_hlcd_hptr]
    ld c, a
    ;; The first byte in the table entry is the rLCDC value to set.
    ASSERT HLCD_Lcdc_u8 == 0
    ldh a, [c]
    ldh [rLCDC], a
    inc c
    ;; The second byte in the table entry is the rSCY value to set.
    ASSERT HLCD_Scy_u8 == 1
    ldh a, [c]
    ldh [rSCY], a
    inc c
    ;; The third byte in the table entry is the next rLYC value to set.
    ASSERT HLCD_NextLyc_u8 == 2
    ldh a, [c]
    ldh [rLYC], a
    inc c
    ;; Now that we've read the whole table entry, store c back into
    ;; Hram_StatNext_hlcd_hptr.
    ASSERT sizeof_HLCD == 3
    ld a, c
    ldh [Hram_StatNext_hlcd_hptr], a
    ;; Restore register state.
    pop bc
    pop af
    reti

;;;=========================================================================;;;

SECTION "InterruptState", HRAM

Hram_VBlank_bool::
    DB

;;; A 1-byte HRAM-pointer (low byte of address) pointing to the HLCD struct to
;;; use for the next STAT interrupt.  While the STAT interrupt is enabled, this
;;; should be reset to LOW(Hram_StatTable_hlcd_arr8) during each VBlank; it
;;; will be be advanced automatically by the STAT interrupt handler.
Hram_StatNext_hlcd_hptr::
    DB

;;; The array of up to 8 HLCD structs that will be used by the STAT interrupt
;;; handler during each frame.  The last entry to be used should have NextLyc
;;; set to 255 to prevent any further STAT interrupts from firing.
Hram_StatTable_hlcd_arr8::
    DS sizeof_HLCD * 8

;;;=========================================================================;;;
