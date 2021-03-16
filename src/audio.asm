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

INCLUDE "src/audio.inc"
INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"

;;;=========================================================================;;;

;;; Bit indices for each channel for the Ram_MusicActiveChannels_u8 bitfield.
ACTB_CH1 EQU 0
ACTB_CH2 EQU 1
ACTB_CH3 EQU 2
ACTB_CH4 EQU 3

;;;=========================================================================;;;

;;; CHAN: Stores the state of one of the four audio channels.
RSRESET
;;; SfxFrames: If zero, then no sound effect is currently active on this
;;;   channel.  If nonzero, then this is the number of frames until we play the
;;;   next SFX block.  Only used for channels 1 and 4.
CHAN_SfxFrames_u8    RB 1
;;; SfxBank: The ROM bank number that the SFX block pointed to by NextSfx is
;;;   stored in.  Only used for channels 1 and 4.
CHAN_SfxBank_u8      RB 1
;;; NextSfx: A pointer to the next SFX block to play, once SfxFrames reaches
;;;   zero.  Only used for channels 1 and 4.
CHAN_NextSfx_ptr     RW 1
;;; NextNote: A pointer to the *next* note to be played on this channel (not
;;;   the note currently playing).
CHAN_NextNote_ptr    RW 1
;;; NoteFrames: The number of frames remaining for the note that's currently
;;;   playing (if any).
CHAN_NoteFrames_u8   RB 1
;;; LastDuration: The duration (in frames) of the most recent TONE note on this
;;;   channel.  This is the duration that will be used by any SAME notes on
;;;   this channel until the next TONE note.
CHAN_LastDuration_u8 RB 1
;;; Instrument: A copy of this channel's currently-selected INST struct from
;;;   the instrument table.
CHAN_Instrument_inst RB sizeof_INST
sizeof_CHAN          RB 0

;;;=========================================================================;;;

SECTION "AudioState", WRAM0

;;; MusicFlag: A boolean flag that can affect the playback of a song via any
;;;   BFEQ opcodes in the song.  This is reset to zero when Func_MusicStart is
;;;   called, and may be changed by SETF opcodes in the song, but can also be
;;;   manually changed before or in between calls to Func_UpdateAudio.
Ram_MusicFlag_bool::
    DB

;;; MusicBank: The ROM bank number that the current song is stored in.
Ram_MusicBank_u8:
    DB

;;; MusicInstTable: A pointer to the current song's instrument table.
Ram_MusicInstTable_ptr:
    DW

;;; MusicSectTable: A pointer to the current song's section table.
Ram_MusicSectTable_ptr:
    DW

;;; MusicOpcode: A pointer to the next music opcode to be executed (once the
;;;   current section, if any, finishes playing).
Ram_MusicOpcode_ptr:
    DW

;;; MusicActiveChannels: A bitfield of which of the four channels are currently
;;;   active (1) or halted (0) for music.  The ACTB_CH? constants specify the
;;;   bit for each channel.
Ram_MusicActiveChannels_u8:
    DB

;;; AudioCh?: The CHAN structs that store the state of each of the four audio
;;;   channels.
Ram_AudioCh1_chan:
    DS sizeof_CHAN
Ram_AudioCh2_chan:
    DS sizeof_CHAN
Ram_AudioCh3_chan:
    DS sizeof_CHAN
Ram_AudioCh4_chan:
    DS sizeof_CHAN

;;;=========================================================================;;;

SECTION "AudioFunctions", ROM0

Data_Null_song:
    DW $0000  ; Instrument table (null ptr)
    DW $0000  ; Section table (null ptr)
    DB $00    ; Opcodes (STOP)

;;; Call this on startup to initialize the audio system.
Func_InitAudio::
    ld a, AUDENA_ON
    ldh [rAUDENA], a
    ld a, $ff
    ldh [rAUDTERM], a
    ld a, $77
    ldh [rAUDVOL], a
    xor a
    ld [Ram_AudioCh1_chan + CHAN_SfxFrames_u8], a
    ld [Ram_AudioCh4_chan + CHAN_SfxFrames_u8], a
    ;; fall through to Func_MusicStop

;;; Call this to stop playing the current song.
Func_MusicStop::
    ld c, BANK(Data_Null_song)
    ld hl, Data_Null_song
    ;; fall through to Func_MusicStart

;;; Call this to start playing a new song.
;;; @param c ROM bank number for song struct.
;;; @param hl Pointer to song struct.
Func_MusicStart::
    ld a, c
    ld [Ram_MusicBank_u8], a
    romb
    ;; Store pointer to instrument table.
    ld a, [hl+]
    ld [Ram_MusicInstTable_ptr + 0], a
    ld a, [hl+]
    ld [Ram_MusicInstTable_ptr + 1], a
    ;; Store pointer to section table.
    ld a, [hl+]
    ld [Ram_MusicSectTable_ptr + 0], a
    ld a, [hl+]
    ld [Ram_MusicSectTable_ptr + 1], a
    ;; Store pointer to first opcode.
    ld a, l
    ld [Ram_MusicOpcode_ptr + 0], a
    ld a, h
    ld [Ram_MusicOpcode_ptr + 1], a
    ;; Reset music state.
    xor a
    ld [Ram_MusicActiveChannels_u8], a
    ld [Ram_MusicFlag_bool], a
    ret

;;;=========================================================================;;;

;;; Call this once per frame to continue playing the current song (if any) and
;;; any active sound effects.
Func_UpdateAudio::
    call Func_UpdateSfx1
    call Func_UpdateSfx4
    ;; Switch ROM bank.
    romb [Ram_MusicBank_u8]
    ;; If we're in the middle of playing a section, keep doing that.
    ld a, [Ram_MusicActiveChannels_u8]
    or a
    jp nz, _UpdateAudio_KeepPlaying
_UpdateAudio_LoadAndExecOpcode:
    ld hl, Ram_MusicOpcode_ptr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
_UpdateAudio_ExecOpcode:
    ld a, [hl]
    bit 6, a
    jr z, .nonFlagOpcode
    and %00111111
    jr z, _UpdateAudio_ExecOpcodeSetf
    jr _UpdateAudio_ExecOpcodeBfeq
    .nonFlagOpcode
    bit 7, a
    jr nz, _UpdateAudio_ExecOpcodePlay
    and %00111111
    jr nz, _UpdateAudio_ExecOpcodeJump
_UpdateAudio_ExecOpcodeHalt:
    ld a, l
    ld [Ram_MusicOpcode_ptr + 0], a
    ld a, h
    ld [Ram_MusicOpcode_ptr + 1], a
    ret
_UpdateAudio_ExecOpcodeBfeq:
    ld a, [Ram_MusicFlag_bool]
    ld b, a
    ld a, [hl]
    and %10000000
    rlca
    xor b
    jr z, _UpdateAudio_ExecOpcodeJump
    inc hl
    jr _UpdateAudio_ExecOpcode
_UpdateAudio_ExecOpcodeJump:
    ld a, [hl]
    bit 5, a
    jr nz, .negJump
    .posJump
    and %00111111
    ld b, 0
    jr .endJump
    .negJump
    or %11000000
    ld b, $ff
    .endJump
    ld c, a
    add hl, bc
    jr _UpdateAudio_ExecOpcode
_UpdateAudio_ExecOpcodeSetf:
    ld a, [hl]
    and %10000000
    rlca
    ld [Ram_MusicFlag_bool], a
    inc hl
    jr _UpdateAudio_ExecOpcode
_UpdateAudio_ExecOpcodePlay:
    ;; Store section ptr offset in bc.
    ASSERT sizeof_SECT == 8
    ld a, [hl]
    and %00011111
    swap a
    rrca
    ldb bc, a
    ;; Store ptr to section table in hl.
    push hl
    ld hl, Ram_MusicSectTable_ptr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ;; Load section.
    add hl, bc
    ld a, [hl+]
    ld [Ram_AudioCh1_chan + CHAN_NextNote_ptr + 0], a
    ld a, [hl+]
    ld [Ram_AudioCh1_chan + CHAN_NextNote_ptr + 1], a
    ld a, [hl+]
    ld [Ram_AudioCh2_chan + CHAN_NextNote_ptr + 0], a
    ld a, [hl+]
    ld [Ram_AudioCh2_chan + CHAN_NextNote_ptr + 1], a
    ld a, [hl+]
    ld [Ram_AudioCh3_chan + CHAN_NextNote_ptr + 0], a
    ld a, [hl+]
    ld [Ram_AudioCh3_chan + CHAN_NextNote_ptr + 1], a
    ld a, [hl+]
    ld [Ram_AudioCh4_chan + CHAN_NextNote_ptr + 0], a
    ld a, [hl+]
    ld [Ram_AudioCh4_chan + CHAN_NextNote_ptr + 1], a
    ;; Mark all four channels as active.
    ld a, %1111
    ld [Ram_MusicActiveChannels_u8], a
    ;; Start playing each channel.
    call Func_MusicStartNoteCh1
    call Func_MusicStartNoteCh2
    call Func_MusicStartNoteCh3
    call Func_MusicStartNoteCh4
    ;; If all channels are already finished, move on to the next opcode.
    pop hl
    inc hl
    ld a, [Ram_MusicActiveChannels_u8]
    or a
    jp z, _UpdateAudio_ExecOpcode
    ;; Otherwise, store pointer to next opcode and return.
    ld a, l
    ld [Ram_MusicOpcode_ptr + 0], a
    ld a, h
    ld [Ram_MusicOpcode_ptr + 1], a
    ret
_UpdateAudio_KeepPlaying:
    ;; Channel 1:
    ld a, [Ram_MusicActiveChannels_u8]
    bit ACTB_CH1, a
    call nz, Func_MusicKeepPlayingCh1
    ;; Channel 2:
    ld a, [Ram_MusicActiveChannels_u8]
    bit ACTB_CH2, a
    call nz, Func_MusicKeepPlayingCh2
    ;; Channel 3:
    ld a, [Ram_MusicActiveChannels_u8]
    bit ACTB_CH3, a
    call nz, Func_MusicKeepPlayingCh3
    ;; Channel 4:
    ld a, [Ram_MusicActiveChannels_u8]
    bit ACTB_CH4, a
    jp nz, Func_MusicKeepPlayingCh4
    ;; If all channels are now finished, move on to the next opcode.
    ld a, [Ram_MusicActiveChannels_u8]
    or a
    jp z, _UpdateAudio_LoadAndExecOpcode
    ret

;;;=========================================================================;;;

;;; Call this to start playing a sound effect on channel 1.
;;; @param c ROM bank number for the sfx1 struct.
;;; @param hl Pointer to sfx1 struct.
Func_PlaySfx1::
    ;; Stop any currently-active sound effect.
    xor a
    ld [Ram_AudioCh1_chan + CHAN_SfxFrames_u8], a
    ;; Store the ROM bank of the sfx1 struct.
    ld a, c
    ld [Ram_AudioCh1_chan + CHAN_SfxBank_u8], a
    ;; Switch ROM banks and begin playing the sound effect.
    jr _UpdateSfx1_SwitchBank

;;; Called by Func_UpdateAudio to continue playing the channel 1 sound effect
;;; (if any).
Func_UpdateSfx1:
    ;; If there's no active sound effect, we're done.
    ld a, [Ram_AudioCh1_chan + CHAN_SfxFrames_u8]
    or a
    ret z
    ;; Decrement the number of remaining frames.  If it's still nonzero, we're
    ;; done.
    dec a
    ld [Ram_AudioCh1_chan + CHAN_SfxFrames_u8], a
    ret nz
    ;; Load pointer to next SFX block into hl.
    ld hl, Ram_AudioCh1_chan + CHAN_NextSfx_ptr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ;; Switch ROM bank.
    ld a, [Ram_AudioCh1_chan + CHAN_SfxBank_u8]
_UpdateSfx1_SwitchBank:
    romb
    ;; Read SFX frames.  If zero, stop the sound.
    ld a, [hl+]
    ld [Ram_AudioCh1_chan + CHAN_SfxFrames_u8], a
    or a
    jr nz, _UpdateSfx1_PlaySound
    ldh [rAUD1ENV], a
    ret
_UpdateSfx1_PlaySound:
    ;; Play the SFX block.
    ld a, [hl+]
    ldh [rAUD1SWEEP], a
    ld a, [hl+]
    ldh [rAUD1LEN], a
    ld a, [hl+]
    ldh [rAUD1ENV], a
    ld a, [hl+]
    ldh [rAUD1LOW], a
    ld a, [hl+]
    ldh [rAUD1HIGH], a
    ;; Store pointer to next SFX block.
    ld a, l
    ld [Ram_AudioCh1_chan + CHAN_NextSfx_ptr + 0], a
    ld a, h
    ld [Ram_AudioCh1_chan + CHAN_NextSfx_ptr + 1], a
    ret

;;;=========================================================================;;;

;;; Call this to start playing a sound effect on channel 4.
;;; @param c ROM bank number for the sfx4 struct.
;;; @param hl Pointer to sfx4 struct.
Func_PlaySfx4::
    ;; Stop any currently-active sound effect.
    xor a
    ld [Ram_AudioCh4_chan + CHAN_SfxFrames_u8], a
    ;; Store the ROM bank of the sfx4 struct.
    ld a, c
    ld [Ram_AudioCh4_chan + CHAN_SfxBank_u8], a
    ;; Switch ROM banks and begin playing the sound effect.
    jr _UpdateSfx4_SwitchBank

;;; Called by Func_UpdateAudio to continue playing the channel 4 sound effect
;;; (if any).
Func_UpdateSfx4:
    ;; If there's no active sound effect, we're done.
    ld a, [Ram_AudioCh4_chan + CHAN_SfxFrames_u8]
    or a
    ret z
    ;; Decrement the number of remaining frames.  If it's still nonzero, we're
    ;; done.
    dec a
    ld [Ram_AudioCh4_chan + CHAN_SfxFrames_u8], a
    ret nz
    ;; Load pointer to next SFX block into hl.
    ld hl, Ram_AudioCh4_chan + CHAN_NextSfx_ptr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ;; Switch ROM bank.
    ld a, [Ram_AudioCh4_chan + CHAN_SfxBank_u8]
_UpdateSfx4_SwitchBank:
    romb
    ;; Read SFX frames.  If zero, stop the sound.
    ld a, [hl+]
    ld [Ram_AudioCh4_chan + CHAN_SfxFrames_u8], a
    or a
    jr nz, _UpdateSfx4_PlaySound
    ldh [rAUD4ENV], a
    ret
_UpdateSfx4_PlaySound:
    ;; Play the SFX block.
    ld a, [hl+]
    ldh [rAUD4LEN], a
    ld a, [hl+]
    ldh [rAUD4ENV], a
    ld a, [hl+]
    ldh [rAUD4POLY], a
    ld a, [hl+]
    ldh [rAUD4GO], a
    ;; Store pointer to next SFX block.
    ld a, l
    ld [Ram_AudioCh4_chan + CHAN_NextSfx_ptr + 0], a
    ld a, h
    ld [Ram_AudioCh4_chan + CHAN_NextSfx_ptr + 1], a
    ret

;;;=========================================================================;;;

Func_MusicKeepPlayingCh1:
    ;; Decrement note frames, and return if the note isn't done yet.
    ld hl, Ram_AudioCh1_chan + CHAN_NoteFrames_u8
    dec [hl]
    ret nz
    ;; Start next note.
    ;; fall through to Func_MusicStartNoteCh1

Func_MusicStartNoteCh1:
    ;; Copy the pointer to the start of the next note into hl.
    ld hl, Ram_AudioCh1_chan + CHAN_NextNote_ptr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
_MusicStartNoteCh1_Decode:
    ld a, [hl+]
    bit 7, a
    jr z, _MusicStartNoteCh1_NoteRestOrHalt
    bit 6, a
    jr z, _MusicStartNoteCh1_NoteInst
    ;; Play note (if the channel is not busy with a sound effect):
    ld b, a
    ld a, [Ram_AudioCh1_chan + CHAN_SfxFrames_u8]
    or a
    jr nz, .skipPlaying
    ld a, [Ram_AudioCh1_chan + CHAN_Instrument_inst + INST_Effect_u8]
    ldh [rAUD1SWEEP], a
    ld a, [Ram_AudioCh1_chan + CHAN_Instrument_inst + INST_Envelope_u8]
    ldh [rAUD1ENV], a
    ld a, [Ram_AudioCh1_chan + CHAN_Instrument_inst + INST_Shape + 0]
    ldh [rAUD1LEN], a
    ld a, [hl+]
    ldh [rAUD1LOW], a
    ld a, b
    and %00000111
    or  %10000000
    ldh [rAUD1HIGH], a
    jr .duration
    .skipPlaying
    inc hl
    ;; Determine duration:
    .duration
    bit 5, b
    jr z, _MusicStartNoteCh1_NoteTone
_MusicStartNoteCh1_NoteSame:
    ld a, [Ram_AudioCh1_chan + CHAN_LastDuration_u8]
    ld [Ram_AudioCh1_chan + CHAN_NoteFrames_u8], a
    jr _MusicStartNoteCh1_Finish
_MusicStartNoteCh1_NoteTone:
    ld a, [hl+]
    ld [Ram_AudioCh1_chan + CHAN_LastDuration_u8], a
    ld [Ram_AudioCh1_chan + CHAN_NoteFrames_u8], a
    jr _MusicStartNoteCh1_Finish
_MusicStartNoteCh1_NoteInst:
    ;; Store instrument ptr offset in bc.
    ASSERT sizeof_INST == 4
    and %00111111
    rlca
    rlca
    ldb bc, a
    ;; Copy the pointer to the start of the instrument table into hl.
    push hl
    ld hl, Ram_MusicInstTable_ptr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ;; Load instrument.
    add hl, bc
    ld a, [hl+]
    ld [Ram_AudioCh1_chan + CHAN_Instrument_inst + INST_Envelope_u8], a
    ld a, [hl+]
    ld [Ram_AudioCh1_chan + CHAN_Instrument_inst + INST_Effect_u8], a
    ld a, [hl]
    ld [Ram_AudioCh1_chan + CHAN_Instrument_inst + INST_Shape + 0], a
    ;; Begin the next note immediately.
    pop hl
    jr _MusicStartNoteCh1_Decode
_MusicStartNoteCh1_NoteRestOrHalt:
    ;; Store the rest duration in d.
    ld d, a
    ;; For both REST and HALT, we disable the channel (if the channel is not
    ;; busy with a sound effect).
    ld a, [Ram_AudioCh1_chan + CHAN_SfxFrames_u8]
    or a
    jr nz, .skipDisable
    ldh [rAUD1ENV], a
    .skipDisable
    ;; If the rest duration is zero, this is a HALT.
    ld a, d
    or a
    jr nz, .rest
    ;; For a HALT, we mark the channel as inactive and return.
    ld hl, Ram_MusicActiveChannels_u8
    res ACTB_CH1, [hl]
    ret
    ;; For a REST, we record the duration.
    .rest
    ld [Ram_AudioCh1_chan + CHAN_NoteFrames_u8], a
    ;; fall through
_MusicStartNoteCh1_Finish:
    ;; Store hl as pointer to start of next note.
    ld a, l
    ld [Ram_AudioCh1_chan + CHAN_NextNote_ptr + 0], a
    ld a, h
    ld [Ram_AudioCh1_chan + CHAN_NextNote_ptr + 1], a
    ret

;;;=========================================================================;;;

Func_MusicKeepPlayingCh2:
    ;; Decrement note frames, and return if the note isn't done yet.
    ld hl, Ram_AudioCh2_chan + CHAN_NoteFrames_u8
    dec [hl]
    ret nz
    ;; Start next note.
    ;; fall through to Func_MusicStartNoteCh2

Func_MusicStartNoteCh2:
    ;; Copy the pointer to the start of the next note into hl.
    ld hl, Ram_AudioCh2_chan + CHAN_NextNote_ptr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
_MusicStartNoteCh2_Decode:
    ld a, [hl+]
    bit 7, a
    jr z, _MusicStartNoteCh2_NoteRestOrHalt
    bit 6, a
    jr z, _MusicStartNoteCh2_NoteInst
    ;; Play note:
    ld b, a
    ld a, [Ram_AudioCh2_chan + CHAN_Instrument_inst + INST_Envelope_u8]
    ldh [rAUD2ENV], a
    ld a, [Ram_AudioCh2_chan + CHAN_Instrument_inst + INST_Shape + 0]
    ldh [rAUD2LEN], a
    ld a, [hl+]
    ldh [rAUD2LOW], a
    ld a, b
    and %00000111
    or  %10000000
    ldh [rAUD2HIGH], a
    ;; Determine duration:
    bit 5, b
    jr z, _MusicStartNoteCh2_NoteTone
_MusicStartNoteCh2_NoteSame:
    ld a, [Ram_AudioCh2_chan + CHAN_LastDuration_u8]
    ld [Ram_AudioCh2_chan + CHAN_NoteFrames_u8], a
    jr _MusicStartNoteCh2_Finish
_MusicStartNoteCh2_NoteTone:
    ld a, [hl+]
    ld [Ram_AudioCh2_chan + CHAN_LastDuration_u8], a
    ld [Ram_AudioCh2_chan + CHAN_NoteFrames_u8], a
    jr _MusicStartNoteCh2_Finish
_MusicStartNoteCh2_NoteInst:
    ;; Store instrument ptr offset in bc.
    ASSERT sizeof_INST == 4
    and %00111111
    rlca
    rlca
    ldb bc, a
    ;; Copy the pointer to the start of the instrument table into hl.
    push hl
    ld hl, Ram_MusicInstTable_ptr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ;; Load instrument.
    add hl, bc
    ld a, [hl+]
    ld [Ram_AudioCh2_chan + CHAN_Instrument_inst + INST_Envelope_u8], a
    inc hl  ; Skip INST_Effect_u8 (unused for ch2)
    ld a, [hl]
    ld [Ram_AudioCh2_chan + CHAN_Instrument_inst + INST_Shape + 0], a
    ;; Begin the next note immediately.
    pop hl
    jr _MusicStartNoteCh2_Decode
_MusicStartNoteCh2_NoteRestOrHalt:
    ;; Store the rest duration in d.
    ld d, a
    ;; For both REST and HALT, we disable the channel.
    xor a
    ldh [rAUD2ENV], a
    ;; If the rest duration is zero, this is a HALT.
    or d
    jr nz, .rest
    ;; For a HALT, we mark the channel as inactive and return.
    ld hl, Ram_MusicActiveChannels_u8
    res ACTB_CH2, [hl]
    ret
    ;; For a REST, we record the duration.
    .rest
    ld [Ram_AudioCh2_chan + CHAN_NoteFrames_u8], a
    ;; fall through
_MusicStartNoteCh2_Finish:
    ;; Store hl as pointer to start of next note.
    ld a, l
    ld [Ram_AudioCh2_chan + CHAN_NextNote_ptr + 0], a
    ld a, h
    ld [Ram_AudioCh2_chan + CHAN_NextNote_ptr + 1], a
    ret

;;;=========================================================================;;;

Func_MusicKeepPlayingCh3:
    ;; Decrement note frames, and return if the note isn't done yet.
    ld hl, Ram_AudioCh3_chan + CHAN_NoteFrames_u8
    dec [hl]
    ret nz
    ;; Start next note.
    ;; fall through to Func_MusicStartNoteCh3

Func_MusicStartNoteCh3:
    ;; Copy the pointer to the start of the next note into hl.
    ld hl, Ram_AudioCh3_chan + CHAN_NextNote_ptr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
_MusicStartNoteCh3_Decode:
    ld a, [hl+]
    bit 7, a
    jr z, _MusicStartNoteCh3_NoteRestOrHalt
    bit 6, a
    jr z, _MusicStartNoteCh3_NoteInst
    ;; Play note:
    ld b, a
    xor a
    ldh [rAUD3ENA], a
    ldh [rAUD3LEN], a
    ld a, %10000000
    ldh [rAUD3ENA], a
    ld a, [Ram_AudioCh3_chan + CHAN_Instrument_inst + INST_Envelope_u8]
    ldh [rAUD3LEVEL], a
    ld a, [hl+]
    ldh [rAUD3LOW], a
    ld a, b
    and %00000111
    or  %10000000
    ldh [rAUD3HIGH], a
    ;; Determine duration:
    bit 5, b
    jr z, _MusicStartNoteCh3_NoteTone
_MusicStartNoteCh3_NoteSame:
    ld a, [Ram_AudioCh3_chan + CHAN_LastDuration_u8]
    ld [Ram_AudioCh3_chan + CHAN_NoteFrames_u8], a
    jr _MusicStartNoteCh3_Finish
_MusicStartNoteCh3_NoteTone:
    ld a, [hl+]
    ld [Ram_AudioCh3_chan + CHAN_LastDuration_u8], a
    ld [Ram_AudioCh3_chan + CHAN_NoteFrames_u8], a
    jr _MusicStartNoteCh3_Finish
_MusicStartNoteCh3_NoteInst:
    ;; Store instrument ptr offset in bc.
    ASSERT sizeof_INST == 4
    and %00111111
    rlca
    rlca
    ldb bc, a
    ;; Copy the pointer to the start of the instrument table into hl.
    push hl
    ld hl, Ram_MusicInstTable_ptr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ;; Load instrument.
    add hl, bc
    ld a, [hl+]
    ld [Ram_AudioCh3_chan + CHAN_Instrument_inst + INST_Envelope_u8], a
    inc hl  ; Skip INST_Effect_u8 (unused for ch3)
    ;; Store the pointer to the WAVE struct in hl.
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ;; We must disable the channel before writing to wave RAM.
    xor a
    ldh [rAUD3ENA], a
    ;; Copy the WAVE struct into wave RAM.
    ld c, LOW(_AUD3WAVERAM)
    ld b, sizeof_WAVE
    .loop
    ld a, [hl+]
    ldh [c], a
    inc c
    dec b
    jr nz, .loop
    ;; Begin the next note immediately.
    pop hl
    jr _MusicStartNoteCh3_Decode
_MusicStartNoteCh3_NoteRestOrHalt:
    ;; Store the rest duration in d.
    ld d, a
    ;; For both REST and HALT, we disable the channel.
    xor a
    ldh [rAUD3ENA], a
    ;; If the rest duration is zero, this is a HALT.
    or d
    jr nz, .rest
    ;; For a HALT, we mark the channel as inactive and return.
    ld hl, Ram_MusicActiveChannels_u8
    res ACTB_CH3, [hl]
    ret
    ;; For a REST, we record the duration.
    .rest
    ld [Ram_AudioCh3_chan + CHAN_NoteFrames_u8], a
    ;; fall through
_MusicStartNoteCh3_Finish:
    ;; Store hl as pointer to start of next note.
    ld a, l
    ld [Ram_AudioCh3_chan + CHAN_NextNote_ptr + 0], a
    ld a, h
    ld [Ram_AudioCh3_chan + CHAN_NextNote_ptr + 1], a
    ret

;;;=========================================================================;;;

Func_MusicKeepPlayingCh4:
    ;; Decrement note frames, and return if the note isn't done yet.
    ld hl, Ram_AudioCh4_chan + CHAN_NoteFrames_u8
    dec [hl]
    ret nz
    ;; Start next note.
    ;; fall through to Func_MusicStartNoteCh4

Func_MusicStartNoteCh4:
    ;; Copy the pointer to the start of the next note into hl.
    ld hl, Ram_AudioCh4_chan + CHAN_NextNote_ptr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
_MusicStartNoteCh4_Decode:
    ld a, [hl+]
    bit 7, a
    jr z, _MusicStartNoteCh4_NoteRestOrHalt
    bit 6, a
    jr z, _MusicStartNoteCh4_NoteInst
    ;; Play note (if the channel is not busy with a sound effect):
    ld b, a
    ld a, [Ram_AudioCh4_chan + CHAN_SfxFrames_u8]
    or a
    jr nz, .skipPlaying
    ld a, [Ram_AudioCh4_chan + CHAN_Instrument_inst + INST_Envelope_u8]
    ldh [rAUD4ENV], a
    ld a, [Ram_AudioCh4_chan + CHAN_Instrument_inst + INST_Effect_u8]
    ldh [rAUD4POLY], a
    ld a, %10000000
    ldh [rAUD4GO], a
    .skipPlaying
    ;; Determine duration:
    bit 5, b
    jr z, _MusicStartNoteCh4_NoteTone
_MusicStartNoteCh4_NoteSame:
    ld a, [Ram_AudioCh4_chan + CHAN_LastDuration_u8]
    ld [Ram_AudioCh4_chan + CHAN_NoteFrames_u8], a
    jr _MusicStartNoteCh4_Finish
_MusicStartNoteCh4_NoteTone:
    ld a, [hl+]
    ld [Ram_AudioCh4_chan + CHAN_LastDuration_u8], a
    ld [Ram_AudioCh4_chan + CHAN_NoteFrames_u8], a
    jr _MusicStartNoteCh4_Finish
_MusicStartNoteCh4_NoteInst:
    ;; Store instrument ptr offset in bc.
    ASSERT sizeof_INST == 4
    and %00111111
    rlca
    rlca
    ldb bc, a
    ;; Copy the pointer to the start of the instrument table into hl.
    push hl
    ld hl, Ram_MusicInstTable_ptr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ;; Load instrument.
    add hl, bc
    ld a, [hl+]
    ld [Ram_AudioCh4_chan + CHAN_Instrument_inst + INST_Envelope_u8], a
    ld a, [hl]
    ld [Ram_AudioCh4_chan + CHAN_Instrument_inst + INST_Effect_u8], a
    ;; Begin the next note immediately.
    pop hl
    jr _MusicStartNoteCh4_Decode
_MusicStartNoteCh4_NoteRestOrHalt:
    ;; Store the rest duration in d.
    ld d, a
    ;; For both REST and HALT, we disable the channel (if the channel is not
    ;; busy with a sound effect).
    ld a, [Ram_AudioCh4_chan + CHAN_SfxFrames_u8]
    or a
    jr nz, .skipDisable
    ldh [rAUD4ENV], a
    .skipDisable
    ;; If the rest duration is zero, this is a HALT.
    ld a, d
    or a
    jr nz, .rest
    ;; For a HALT, we mark the channel as inactive and return.
    ld hl, Ram_MusicActiveChannels_u8
    res ACTB_CH4, [hl]
    ret
    ;; For a REST, we record the duration.
    .rest
    ld [Ram_AudioCh4_chan + CHAN_NoteFrames_u8], a
    ;; fall through
_MusicStartNoteCh4_Finish:
    ;; Store hl as pointer to start of next note.
    ld a, l
    ld [Ram_AudioCh4_chan + CHAN_NextNote_ptr + 0], a
    ld a, h
    ld [Ram_AudioCh4_chan + CHAN_NextNote_ptr + 1], a
    ret

;;;=========================================================================;;;
