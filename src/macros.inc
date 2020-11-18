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
;;;     if_eq 9, jr, .label  ; Jump-relative to .label if a == 9.
;;;     if_eq b, call, Func  ; call Func if a == b.
;;;     if_eq 0, ret         ; Return if a == 0.
if_eq: MACRO
    cp \1
    IF _NARG > 2
    \2 z, \3
    ELSE
    \2 z
    ENDC
ENDM

;;; Executes a conditional instruction if `a` is strictly less than the first
;;; argument (constant or register) when treated as unsigned.  This will
;;; change `f`, but preserve other registers.
;;;
;;; Examples:
;;;     if_lt 9, jr, .label  ; Jump-relative to .label if a < 9 (unsigned).
;;;     if_lt b, call, Func  ; call Func if a < b (unsigned).
;;;     if_lt 7, ret         ; Return if a < 7 (unsigned).
if_lt: MACRO
    cp \1
    IF _NARG > 2
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
;;;     if_ge 9, jr, .label  ; Jump-relative to .label if a >= 9 (unsigned).
;;;     if_ge b, call, Func  ; call Func if a >= b (unsigned).
;;;     if_ge 1, ret         ; Return if a >= 1 (unsigned).
if_ge: MACRO
    cp \1
    IF _NARG > 2
    \2 nc, \3
    ELSE
    \2 nc
    ENDC
ENDM

;=============================================================================;
