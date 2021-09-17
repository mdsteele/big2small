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

INCLUDE "src/areamap.inc"
INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"

;;;=========================================================================;;;

SHIP_PALETTE   EQU (OAMF_PAL1 | 5)
THRUST_PALETTE EQU (OAMF_PAL1 | 6)

SHIP_L_TILEID   EQU $b2
SHIP_M_TILEID   EQU $b4
SHIP_R_TILEID   EQU $b6
THRUST_1_TILEID EQU $b8

;;;=========================================================================;;;

SECTION "AreaObjFunctions", ROM0

;;; Initializes any non-avatar objects needed for the specified area map.
;;; @param c The current area number.
Func_AreaMapInitExtraObjs::
    ld a, c
    if_ne AREA_SPACE, ret
_AreaMapInitExtraObjs_Space:
    ld a, 32
    ld [Ram_ShipL_oama + OAMA_Y], a
    ld [Ram_ShipM_oama + OAMA_Y], a
    ld [Ram_ShipR_oama + OAMA_Y], a
    ld a, 128
    ld [Ram_ShipL_oama + OAMA_X], a
    add 8
    ld [Ram_ShipM_oama + OAMA_X], a
    add 8
    ld [Ram_ShipR_oama + OAMA_X], a
    ld a, SHIP_PALETTE
    ld [Ram_ShipL_oama + OAMA_FLAGS], a
    ld [Ram_ShipM_oama + OAMA_FLAGS], a
    ld [Ram_ShipR_oama + OAMA_FLAGS], a
    ld a, SHIP_L_TILEID
    ld [Ram_ShipL_oama + OAMA_TILEID], a
    ld a, SHIP_M_TILEID
    ld [Ram_ShipM_oama + OAMA_TILEID], a
    ld a, SHIP_R_TILEID
    ld [Ram_ShipR_oama + OAMA_TILEID], a
    ret

;;; Animates the ship departing the space station.
Func_AreaMapSpaceshipDepart::
    ;; Hide the avatar object.
    xor a
    ld [Ram_Avatar_oama + OAMA_Y], a
    ;; Initialize loop.
    PLAY_SFX1 DataX_EnterShip_sfx1
    ld c, 60
_AreaMapSpaceshipDepart_WaitLoop:
    push bc
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_AnimateTiles
    pop bc
    dec c
    jr nz, _AreaMapSpaceshipDepart_WaitLoop
_AreaMapSpaceshipDepart_InitThrust:
    ;; Set up the thrust object.
    ld a, 32
    ld [Ram_Thrust_oama + OAMA_Y], a
    ld a, 124
    ld [Ram_Thrust_oama + OAMA_X], a
    ld a, THRUST_PALETTE
    ld [Ram_Thrust_oama + OAMA_FLAGS], a
    ld a, THRUST_1_TILEID
    ld [Ram_Thrust_oama + OAMA_TILEID], a
    ;; Initialize loop.
    PLAY_SFX4 DataX_LaunchShip_sfx4
    ld c, 124  ; ship/thrust X-position
    ld b, 0    ; ship velocity
_AreaMapSpaceshipDepart_ThrustLoop:
    push bc
    call Func_UpdateAudio
    call Func_WaitForVBlankAndPerformDma
    call Func_AnimateTiles
    pop bc
    ;; If the ship/thrust is now off the right side of the screen, we're done.
    ld a, c
    if_ge SCRN_X + 8, ret
    ;; Accelerate the ship's velocity.
    inc b
    ;; Add velocity/16 to the X-position.
    ld a, b
    swap a
    and $0f
    add c
    ld c, a
    ;; Update the X-positions of each object in the ship.
    ld [Ram_Thrust_oama + OAMA_X], a
    add 5
    ld [Ram_ShipL_oama + OAMA_X], a
    add 8
    ld [Ram_ShipM_oama + OAMA_X], a
    add 8
    ld [Ram_ShipR_oama + OAMA_X], a
    ;; Animate the thrust tile ID.
    ld a, b
    if_ge 15, jr, _AreaMapSpaceshipDepart_ThrustLoop
    and %00000010
    ld d, a
    ld a, [Ram_Thrust_oama + OAMA_TILEID]
    and %11111100
    or d
    ld [Ram_Thrust_oama + OAMA_TILEID], a
    jr _AreaMapSpaceshipDepart_ThrustLoop

;;;=========================================================================;;;
