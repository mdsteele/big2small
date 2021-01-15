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

SECTION "HeaderInit", ROM0[$0100]
    ;; Execution starts here.
    nop
    jp Main

SECTION "HeaderLogo", ROM0[$0104]
    ;; $0104-$0133: Nintendo logo
    DS 48  ; This gets filled in by rgbfix.

SECTION "HeaderTitle", ROM0[$0134]
Data_HeaderTitle:
    ;; 11-byte-max game title, padded with zeros.
    DB "BIG2SMALL", 0, 0
    ASSERT @ - Data_HeaderTitle == 11

SECTION "HeaderMetadata", ROM0[$013f]
    ;; $013F-$0142: Manufacturer code
    DS 4  ; blank
    ;; $0143: Game Boy Color flag
    DB CART_COMPATIBLE_DMG
    ;; $0144-$0145: New licensee code
    DW $0000  ; none
    ;; $0146: Super Game Boy indicator
    DB CART_INDICATOR_GB
    ;; $0147: Cartridge type
    DB CART_ROM_MBC5_RAM_BAT
    ;; $0148: ROM size
    DB CART_ROM_32KB
    ;; $0149: RAM size
    DB CART_SRAM_8KB
    ;; $014A: Destination code
    DB CART_DEST_NON_JAPANESE
    ;; $014B: Old licensee code
    DB $33  ; Use new licensee code
    ;; $014C: Mask ROM version
    DB $00
    ;; $014D: Header checksum
    DB $00  ; This gets filled in by rgbfix.
    ;; $014E-$014F: Global checksum
    DW $0000  ; This gets filled in by rgbfix.

;;;=========================================================================;;;
