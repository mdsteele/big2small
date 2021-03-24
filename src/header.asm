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

;;;=========================================================================;;;

SECTION "Header", ROM0[$0100]
    ;; $0100-$0104: Execution starts here.
    nop
    jp Main

    ;; $0104-$0133: Nintendo logo
    STATIC_ASSERT @ == $0104
    DS $30  ; This gets filled in by rgbfix.

    ;; $0134-$013e: 11-byte-max game title, padded with zeros.
    STATIC_ASSERT @ == $0134
    DB "BIG2SMALL", 0, 0
    STATIC_ASSERT @ == $013f

    ;; $013f-$0142: Manufacturer code
    DB 0, 0, 0, 0  ; blank
    ;; $0143: Game Boy Color flag
    DB CART_COMPATIBLE_DMG_GBC
    ;; $0144-$0145: New licensee code
    DW $0000  ; none
    ;; $0146: Super Game Boy indicator
    DB CART_INDICATOR_GB
    ;; $0147: Cartridge type
    DB CART_ROM_MBC5_RAM_BAT
    ;; $0148: ROM size
    DB CART_ROM_64KB
    ;; $0149: RAM size
    DB CART_SRAM_8KB
    ;; $014a: Destination code
    DB CART_DEST_NON_JAPANESE
    ;; $014b: Old licensee code
    DB $33  ; Use new licensee code
    ;; $014c: Mask ROM version
    DB $00
    ;; $014d: Header checksum
    DB $00  ; This gets filled in by rgbfix.
    ;; $014e-$014f: Global checksum
    DW $0000  ; This gets filled in by rgbfix.
    STATIC_ASSERT @ == $0150

;;;=========================================================================;;;
