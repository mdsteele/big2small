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

;;; Executes a conditional instruction if `a` is equal to the first argument
;;; (constant or register).  This will change `f`, but preserve other
;;; registers.
;;;
;;; Examples:
;;;     if_eq 9, jr, .label  ; jump-relative to .label if a == 9
;;;     if_eq b, call, Func  ; call Func if a == b
;;;     if_eq 0, ret         ; return if a == 0
if_eq: MACRO
    IF _NARG < 2
    FAIL "Too few arguments to if_eq macro"
    ENDC
    cp \1
    IF _NARG > 3
    FAIL "Too many arguments to if_eq macro"
    ELIF _NARG > 2
    \2 z, \3
    ELSE
    \2 z
    ENDC
ENDM

;;; Executes a conditional instruction if `a` is not equal to the first
;;; argument (constant or register).  This will change `f`, but preserve other
;;; registers.
;;;
;;; Examples:
;;;     if_ne 9, jr, .label  ; jump-relative to .label if a != 9
;;;     if_ne b, call, Func  ; call Func if a != b
;;;     if_ne 0, ret         ; return if a != 0
if_ne: MACRO
    IF _NARG < 2
    FAIL "Too few arguments to if_ne macro"
    ENDC
    cp \1
    IF _NARG > 3
    FAIL "Too many arguments to if_ne macro"
    ELIF _NARG > 2
    \2 nz, \3
    ELSE
    \2 nz
    ENDC
ENDM

;;; Executes a conditional instruction if `a` is strictly less than the first
;;; argument (constant or register) when treated as unsigned.  This will
;;; change `f`, but preserve other registers.
;;;
;;; Examples:
;;;     if_lt 9, jr, .label  ; jump-relative to .label if a < 9 (unsigned)
;;;     if_lt b, call, Func  ; call Func if a < b (unsigned)
;;;     if_lt 7, ret         ; return if a < 7 (unsigned)
if_lt: MACRO
    IF _NARG < 2
    FAIL "Too few arguments to if_lt macro"
    ENDC
    cp \1
    IF _NARG > 3
    FAIL "Too many arguments to if_lt macro"
    ELIF _NARG > 2
    \2 c, \3
    ELSE
    \2 c
    ENDC
ENDM

;;; Executes a conditional instruction if `a` is greater than or equal to the
;;; first argument (constant or register) when treated as unsigned.  This will
;;; change `f`, but preserve other registers.
;;;
;;; Examples:
;;;     if_ge 9, jr, .label  ; jump-relative to .label if a >= 9 (unsigned)
;;;     if_ge b, call, Func  ; call Func if a >= b (unsigned)
;;;     if_ge 1, ret         ; return if a >= 1 (unsigned)
if_ge: MACRO
    IF _NARG < 2
    FAIL "Too few arguments to if_ge macro"
    ENDC
    cp \1
    IF _NARG > 3
    FAIL "Too many arguments to if_ge macro"
    ELIF _NARG > 2
    \2 nc, \3
    ELSE
    \2 nc
    ENDC
ENDM

;;; Executes a conditional instruction if running on a color-enabled device.
;;; This will change `af`, but preserve other registers.
;;;
;;; Examples:
;;;     if_cgb jr, .label  ; jump-relative to .label if running on a CGB
;;;     if_cgb call, Func  ; call Func if running on a CGB
;;;     if_cgb ret         ; return if running on a CGB
if_cgb: MACRO
    ldh a, [Hram_ColorEnabled_bool]
    or a
    IF _NARG == 1
    \1 nz
    ELIF _NARG == 2
    \1 nz, \2
    ELSE
    FAIL "Wrong number of arguments to if_cgb macro"
    ENDC
ENDM

;;; Executes a conditional instruction if NOT running on a color-enabled
;;; device.  This will change `af`, but preserve other registers.
;;;
;;; Examples:
;;;     if_dmg jr, .label  ; jump-relative to .label if running on a DMG
;;;     if_dmg call, Func  ; call Func if running on a DMG
;;;     if_dmg ret         ; return if running on a DMG
if_dmg: MACRO
    ldh a, [Hram_ColorEnabled_bool]
    or a
    IF _NARG == 1
    \1 z
    ELIF _NARG == 2
    \1 z, \2
    ELSE
    FAIL "Wrong number of arguments to if_dmg macro"
    ENDC
ENDM

;;;=========================================================================;;;

;;; If hl points to a 2-byte little-endian value stored in memory (such as
;;; another pointer), this reads that value into the specified 16-bit register.
;;; The a and hl registers are destroyed in the process.
;;;
;;; Examples:
;;;     deref de, hl  ; stores [hl] in e and [hl+1] in d, destroying a and hl
;;;     deref hl, hl  ; replaces hl with the value hl pointed to, destroying a
;;;     deref hl      ; shorthand for "deref hl, hl"
deref: MACRO
    IF _NARG < 1
    FAIL "Too few arguments to deref macro"
    ELIF _NARG == 1
    STATIC_ASSERT "\1" == "hl"
    ld a, [hl+]
    ld HIGH(hl), [hl]
    ld LOW(hl), a
    ELIF _NARG == 2
    STATIC_ASSERT "\2" == "hl"
    ld a, [hl+]
    ld HIGH(\1), [hl]
    ld LOW(\1), a
    ELSE
    FAIL "Too many arguments to deref macro"
    ENDC
ENDM

;;; Loads an 8-bit register into a 16-bit register (using two ld instructions).
;;;
;;; Examples:
;;;     ldb bc, a     ; sets c to a, and sets b to 0
;;;     ldb de, d     ; sets e to d, then sets d to 0
;;;     ldb hl, [hl]  ; sets l to [hl], then sets h to 0
ldb: MACRO
    IF _NARG < 2
    FAIL "Too few arguments to ldb macro"
    ELIF _NARG > 2
    FAIL "Too many arguments to ldb macro"
    ENDC
    ld LOW(\1), \2
    ld HIGH(\1), 0
ENDM

;;; Loads one 16-bit register into another (using two ld instructions).
;;;
;;; Examples:
;;;     ldw bc, de  ; sets c to e, and sets b to d
;;;     ldw hl, bc  ; sets l to c, and sets h to b
ldw: MACRO
    IF _NARG < 2
    FAIL "Too few arguments to ldw macro"
    ELIF _NARG > 2
    FAIL "Too many arguments to ldw macro"
    ENDC
    ld LOW(\1), LOW(\2)
    ld HIGH(\1), HIGH(\2)
ENDM

;;;=========================================================================;;;

;;; Multiplies the `a` register by a fixed constant (only small powers of two
;;; are supported).  Sets/clears the `z` and `c` flags as appropriate.
;;; Examples:
;;;     mult 2  ; multiplies a by 2
;;;     mult 4  ; multiplies a by 4
mult: MACRO
    STATIC_ASSERT _NARG == 1
    IF (\1) == 2
    add a
    ELIF (\1) == 4
    add a
    add a
    ELIF (\1) == 8
    add a
    add a
    add a
    ELSE
    FAIL "Unsupported mult factor"
    ENDC
ENDM

;;; Negates the `a` register.  Sets/clears the `z` flag if the result is
;;; zero/nonzero.
neg: MACRO
    IF _NARG > 0
    FAIL "Too many arguments to neg macro"
    ENDC
    cpl
    inc a
ENDM

;;;=========================================================================;;;

;;; Sets the current ROM bank.  Without any argument, sets the bank to the
;;; value of the a register.  With an argument, sets both the bank and the a
;;; register to the value of that argument.
;;;
;;; Examples:
;;;     romb [Ram_Bank_u8]   ; sets both a and ROM bank to value of Ram_Bank_u8
;;;     romb BANK(DataX_Foo) ; sets both a and ROM bank to given bank number
;;;     romb                 ; sets ROM bank to value of a
romb: MACRO
    IF _NARG > 1
    FAIL "Too many arguments to romb macro"
    ELIF _NARG > 0
    ld a, \1
    ENDC
    ld [$2000], a
ENDM

;;; Loads a ROMX address into a 16-bit register after first switching to its
;;; ROM bank.  This also stores the new ROM bank number in the a register.
;;;
;;; Examples:
;;;     xld hl, DataX_Sb  ; sets hl to DataX_Sb and ROM bank to BANK(DataX_Sb)
;;;     xld de, DataX_Ag  ; sets de to DataX_Ag and ROM bank to BANK(DataX_Ag)
xld: MACRO
    IF _NARG < 2
    FAIL "Too few arguments to xld macro"
    ELIF _NARG > 2
    FAIL "Too many arguments to xld macro"
    ENDC
    ASSERT BANK(@) == 0
    ASSERT BANK(\2) != 0
    romb BANK(\2)
    ld \1, \2
ENDM

;;; Calls a function stored in ROMX after first switching to its ROM bank.
;;; This also stores the new ROM bank number in the a register (before calling
;;; the function).
;;;
;;; Examples:
;;;     xcall FuncX_Foo
xcall: MACRO
    IF _NARG < 1
    FAIL "Too few arguments to xcall macro"
    ELIF _NARG > 1
    FAIL "Too many arguments to xcall macro"
    ENDC
    ASSERT BANK(@) == 0
    ASSERT BANK(\1) != 0
    romb BANK(\1)
    call \1
ENDM

;;; Allows code in ROMX to safely call a function in ROM0 that doesn't
;;; preserve the ROM bank.  The hl register is destroyed in the process, so
;;; this cannot be used to call functions that use hl as a parameter.
;;;
;;; Examples:
;;;     zcall Func_Foo
zcall: MACRO
    STATIC_ASSERT _NARG == 1
    ASSERT BANK(@) != 0
    ASSERT BANK(\1) == 0
    ld a, BANK(@)
    ld hl, \1
    rst Rst_Trampoline
ENDM

;;;=========================================================================;;;

;;; Copies data from the current ROM bank.
COPY_FROM_CURR: MACRO
    IF _NARG < 2
    FAIL "Too few arguments to COPY_FROM_CURR macro"
    ELIF _NARG > 2
    FAIL "Too many arguments to COPY_FROM_CURR macro"
    ENDC
    ASSERT BANK(\1) == BANK(\2)
    ld de, (\1)
    ld bc, (\2) - (\1)
    call Func_MemCopy
ENDM

;;; Copies data from ROMX, after first changing the current ROM bank.
COPY_FROM_ROMX: MACRO
    IF _NARG < 2
    FAIL "Too few arguments to COPY_FROM_ROMX macro"
    ELIF _NARG > 2
    FAIL "Too many arguments to COPY_FROM_ROMX macro"
    ENDC
    ASSERT BANK(\1) != 0
    ASSERT BANK(\2) != 0
    ASSERT BANK(\1) == BANK(\2)
    romb BANK(\1)
    COPY_FROM_CURR \1, \2
ENDM

;;; Copies data from ROM0 (without changing the current ROM bank).
;;;
;;; Examples:
;;;     COPY_FROM_ROM0 Data_Foo_start, Data_Foo_end  ; must be in bank zero
COPY_FROM_ROM0: MACRO
    IF _NARG < 2
    FAIL "Too few arguments to COPY_FROM_ROM0 macro"
    ELIF _NARG > 2
    FAIL "Too many arguments to COPY_FROM_ROM0 macro"
    ENDC
    ASSERT BANK(\1) == 0
    ASSERT BANK(\2) == 0
    COPY_FROM_CURR \1, \2
ENDM

;;; Copies data from the same ROM bank as the calling function (without
;;; changing the current ROM bank).
COPY_FROM_SAME: MACRO
    IF _NARG < 2
    FAIL "Too few arguments to COPY_FROM_SAME macro"
    ELIF _NARG > 2
    FAIL "Too many arguments to COPY_FROM_SAME macro"
    ENDC
    ASSERT BANK(\1) == BANK(@)
    ASSERT BANK(\2) == BANK(@)
    COPY_FROM_CURR \1, \2
ENDM

;;;=========================================================================;;;

PLAY_SFX1: MACRO
    IF _NARG < 1
    FAIL "Too few arguments to PLAY_SFX1 macro"
    ELIF _NARG > 1
    FAIL "Too many arguments to PLAY_SFX1 macro"
    ENDC
    ASSERT STRCMP(STRSUB("\1", STRLEN("\1") - 4, 5), "_sfx1") == 0
    ld c, BANK(\1)
    ld hl, \1
    call Func_PlaySfx1
ENDM

PLAY_SFX4: MACRO
    IF _NARG < 1
    FAIL "Too few arguments to PLAY_SFX4 macro"
    ELIF _NARG > 1
    FAIL "Too many arguments to PLAY_SFX4 macro"
    ENDC
    ASSERT STRCMP(STRSUB("\1", STRLEN("\1") - 4, 5), "_sfx4") == 0
    ld c, BANK(\1)
    ld hl, \1
    call Func_PlaySfx4
ENDM

PLAY_SONG: MACRO
    IF _NARG < 1
    FAIL "Too few arguments to PLAY_SONG macro"
    ELIF _NARG > 1
    FAIL "Too many arguments to PLAY_SONG macro"
    ENDC
    ASSERT STRCMP(STRSUB("\1", STRLEN("\1") - 4, 5), "_song") == 0
    ld c, BANK(\1)
    ld hl, \1
    call Func_MusicStart
ENDM

;;;=========================================================================;;;
