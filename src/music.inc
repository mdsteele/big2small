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

;;; WAVE: Describes a ch3 waveform.
RSRESET
WAVE_Bytes_start RB 16
sizeof_WAVE      RB 0

;;;=========================================================================;;;

;;; SONG: Describes a song.  This is a variable-sized struct; it holds two
;;;   pointers and a variable-sized array of music opcode bytes.  All data for
;;;   a given song (including opcodes, instruments, sections, and notes) must
;;;   be stored in the same ROM bank.
RSRESET
;;; InstTable: Stores a pointer to the song's instrument table, which is an
;;;   array of up to 64 INST structs.  Multiple songs can share the same
;;;   instrument table (as long as those songs are all in the same ROM bank).
SONG_InstTable_ptr RW 1
;;; SectTable: Stores a pointer to the song's section table, which is an array
;;;   of up to 32 SECT structs.
SONG_SectTable_ptr RW 1
;;; Opcodes: The start of an array of one or more music opcode bytes.  The
;;;   opcode decoding scheme is as follows:
;;;     - STOP [%00000000].  Ends the song.  No more opcodes will be executed
;;;       (nor sound produced) on future calls to Func_MusicUpdate until
;;;       Func_MusicStart is called to begin a new song.
;;;     - JUMP [%00xxxxxx].  Jumps forward/backward by %xxxxxx opcodes from
;;;       this one (signed).  For example, a JUMP value of 2 would skip the
;;;       next opcode, and proceed to the one after.
;;;     - SETF [%y1000000].  Sets Ram_MusicFlag_bool to %y.
;;;     - BFEQ [%y1xxxxxx].  If Ram_MusicFlag_bool is equal to %y, jumps
;;;       forward/backward by %xxxxxx opcodes from this one (signed).
;;;       Otherwise, does nothing (and proceeds to the next opcode).
;;;     - PLAY [%100xxxxx].  Plays section number %xxxxx (0-31).  The next
;;;       opcode will be executed when the section is finished.
SONG_Opcodes_start RB 0

;;;=========================================================================;;;

;;; INST: Describes an instrument in a song's instrument table.  The fields are
;;;   interpreted differently depending on the channel.  It is possible to
;;;   share the same instruement between ch1 and ch2, or between ch2 and ch4,
;;;   but otherwise each channel will in general need their own instruments.
RSRESET
;;; Envelope: This specifies the value for the NR?2 register (envelope for
;;;   ch1/ch2/ch4, or level for ch3).
INST_Envelope_u8 RB 1
;;; Effect: For ch1, this specifies the value for the sweep register (NR10).
;;;   For ch4, this specifies the value for the poly register (NR43).  For
;;;   ch2/ch3, this is ignored.
INST_Effect_u8   RB 1
;;; Shape: For ch1/ch2, the first byte specifies the value for the duty/length
;;;   register (NR?1), and the second byte is ignored.  For ch3, this stores a
;;;   pointer to a WAVE struct.  For ch4, this is ignored.
INST_Shape       RW 1
sizeof_INST      RB 0

;;;=========================================================================;;;

;;; SECT: Describes one section of a song.  It consists of four pointers, one
;;;   for each channel, each pointing to a sequence of one or more notes.  Note
;;;   sequences can be shared between sections (or even between songs, if those
;;;   songs are all in the same ROM bank).  Note sequences can also be shared
;;;   between channels, but beware that note decoding works differently for ch4
;;;   than for the other three channels.
RSRESET
;;; Notes1: Stores a pointer to the note sequence for ch1.  The note decoding
;;;   scheme is as follows:
;;;     - HALT (1 byte) [%00000000].  Silences this channel until the end of
;;;       the section.  The sequence must always end with a HALT note.
;;;     - REST (1 byte) [%0xxxxxxx].  Silences this channel for %xxxxxxx
;;;       frames (1-127).
;;;     - INST (1 byte) [%10xxxxxx].  Sets this channel to use instrument
;;;       number %xxxxxx from the instrument table.  The chosen instrument
;;;       will persist across sections, until the next INST note is executed.
;;;     - TONE (3 bytes) [%11000xxx %yyyyyyyy %zzzzzzzz].  Plays a tone with
;;;       frequency value %xxxyyyyyyyy (0-2047) for %zzzzzzzz frames (1-255).
;;;     - SAME (2 bytes) [%11100xxx %yyyyyyyy].  Plays a tone with frequency
;;;       value %xxxyyyyyyyy (0-2047) for the same number of frames as the most
;;;       recent TONE note.
SECT_Notes1_ptr RW 1
;;; Notes2: Stores a pointer to the note sequence for ch2 (using the same note
;;;   decoding scheme as ch1).
SECT_Notes2_ptr RW 1
;;; Notes3: Stores a pointer to the note sequence for ch3 (using the same note
;;;   decoding scheme as ch1).
SECT_Notes3_ptr RW 1
;;; Notes4: Stores a pointer to the note sequence for ch4.  The note decoding
;;;   scheme is as follows:
;;;     - HALT/REST/INST: Same as for ch1, ch2, and ch3.
;;;     - TONE (2 bytes) [%11000000 %zzzzzzzz].  Plays a sound for %zzzzzzzz
;;;       frames (1-255).
;;;     - SAME (1 byte) [%11100000].  Plays a sound for the same number of
;;;       frames as the most recent TONE note.
SECT_Notes4_ptr RW 1
sizeof_SECT     RB 0

;;;=========================================================================;;;
