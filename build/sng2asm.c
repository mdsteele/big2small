/*=============================================================================
| Copyright 2020 Matthew D. Steele <mdsteele@alum.mit.edu>                    |
|                                                                             |
| This file is part of Big2Small.                                             |
|                                                                             |
| Big2Small is free software: you can redistribute it and/or modify it under  |
| the terms of the GNU General Public License as published by the Free        |
| Software Foundation, either version 3 of the License, or (at your option)   |
| any later version.                                                          |
|                                                                             |
| Big2Small is distributed in the hope that it will be useful, but WITHOUT    |
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or       |
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for   |
| more details.                                                               |
|                                                                             |
| You should have received a copy of the GNU General Public License along     |
| with Big2Small.  If not, see <http://www.gnu.org/licenses/>.                |
=============================================================================*/

#include <assert.h>
#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*===========================================================================*/

#define BYTES_PER_WAVE 16
#define HALF_STEPS_PER_OCTAVE 12
#define MAX_BYTES_PER_NOTE 3
#define MAX_INSTRUMENTS 64
#define MAX_INTEGER_DIGITS 6
#define MAX_NOTES_PER_CHANNEL 1000
#define MAX_PARTS_PER_SONG 26
#define MAX_QUOTED_STRING_CHARS 256
#define MAX_SONGS_PER_FILE 64
#define MAX_WAVES MAX_INSTRUMENTS
#define NUM_CHANNELS 4

// Pitch number (in half steps above c0) and frequency (in Hz) of a4:
#define A4_PITCH (9 + 4 * HALF_STEPS_PER_OCTAVE)
#define A4_FREQUENCY 440.0

/*===========================================================================*/

typedef struct {
  unsigned char data[BYTES_PER_WAVE];
} sng_wave_t;

typedef struct {
  int envelope;
  int effect;
  int duty;
  int wave;
} sng_instrument_t;

typedef struct {
  enum {
    NOTE_REST = 0,
    NOTE_INST,
    NOTE_TONE,
  } kind;
  unsigned char frames;
  unsigned short value;
} sng_note_t;

typedef struct {
  int num_notes;
  sng_note_t *notes;
  int num_bytes;
  unsigned char *bytes;
} sng_channel_t;

typedef struct {
  sng_channel_t *channel; // not owned
  int num_labels;
  char **labels;
} sng_sequence_t;

typedef struct {
  sng_channel_t *channels; // NULL if this part does not exist
  int index;
} sng_part_t;

typedef struct {
  const char *title;
  const char *spec;
  sng_part_t *parts; // array of MAX_PARTS_PER_SONG parts
  int num_opcodes;
  unsigned char *opcodes;
} sng_song_t;

struct {
  int current_char; // the most recent character read
  int line;
  int num_waves;
  sng_wave_t waves[MAX_WAVES];
  int num_instruments;
  sng_instrument_t instruments[MAX_INSTRUMENTS];
  int num_songs;
  sng_song_t songs[MAX_SONGS_PER_FILE];
  int num_sequences;
  sng_sequence_t *sequences;
  enum {
    BEGIN_LINE,
    NEW_NOTE,
    ADJUST_PITCH,
    CONTINUE_DURATION,
    BEGIN_DURATION,
    ADJUST_DURATION,
    INSTRUMENT,
    AFTER_DECL_OR_DIR,
    LINE_COMMENT
  } state;
  int frames_per_whole_note;
  int current_part;
  int current_channel;
  int current_key; // -k = k flats, +k = k sharps
  int named_pitch; // -1 = rest, 0 = C, 1 = C#, ..., 11 = B
  int base_pitch; // initially, named_pitch with current_key applied
  int pitch_adjust; // 1 = sharp, -1 = flat
  int octave;
  int base_duration; // measured in frames
  int extra_duration; // measured in frames
  sng_instrument_t current_instrument;
} parser;

/*===========================================================================*/

#define PARSE_ERROR(...) do { \
    fprintf(stderr, "line %d: parse error: ", parser.line); \
    fprintf(stderr, __VA_ARGS__); \
    exit(EXIT_FAILURE); \
  } while (0)

static void begin_line(void) {
  parser.state = BEGIN_LINE;
  parser.named_pitch = 0;
  parser.base_pitch = 0;
  parser.pitch_adjust = 0;
  parser.octave = 4;
  parser.base_duration = parser.frames_per_whole_note;
  parser.extra_duration = 0;
}

static void init_parser(void) {
  parser.frames_per_whole_note = 96;
  parser.current_part = -1;
  parser.current_channel = -1;
  parser.line = 1;
  begin_line();
}

static int next_char(void) {
  const int ch = fgetc(stdin);
  if (parser.current_char == '\n') ++parser.line;
  parser.current_char = ch;
  return ch;
}

static int peek_char(void) {
  const int ch = fgetc(stdin);
  ungetc(ch, stdin);
  return ch;
}

/*===========================================================================*/

static void finish_current_song(void) {
  if (parser.num_songs == 0) return;
  // Number parts:
  sng_song_t *song = &parser.songs[parser.num_songs - 1];
  for (int p = 0, index = 0; p < MAX_PARTS_PER_SONG; ++p) {
    sng_part_t *part = &song->parts[p];
    if (part->channels == NULL) continue;
    part->index = index++;
  }
  // Count opcodes:
  song->num_opcodes = 1;
  for (const char *ptr = song->spec; *ptr != '\0'; ++ptr) {
    const char ch = *ptr;
    if (ch >= 'A' && ch <= 'Z') ++song->num_opcodes;
    // TODO: Support JUMP, SETF, and BFEQ opcodes
  }
  song->opcodes = calloc(song->num_opcodes, sizeof(unsigned char));
  // Compile opcodes:
  int pc = 0;
  int loop_point = -1;
  for (const char *ptr = song->spec; *ptr != '\0'; ++ptr) {
    const char ch = *ptr;
    if (ch >= 'A' && ch <= 'Z') {
      sng_part_t *part = &song->parts[ch - 'A'];
      if (part->channels == NULL) {
        PARSE_ERROR("song \"%s\" has no part %c\n", song->title, ch);
      }
      song->opcodes[pc++] = 0x80 | part->index;
    } else if (ch == '|') {
      if (loop_point != -1) {
        PARSE_ERROR("song \"%s\" spec has multiple loop points\n",
                    song->title);
      }
      loop_point = pc;
    } else {
      PARSE_ERROR("unexpected '%c' in song \"%s\" spec\n", ch, song->title);
    }
  }
  assert(pc + 1 == song->num_opcodes);
  song->opcodes[pc] = loop_point >= 0 ? 0x3f & (loop_point - pc) : 0x00;
  // Compile notes:
  for (int p = 0; p < MAX_PARTS_PER_SONG; ++p) {
    sng_part_t *part = &song->parts[p];
    if (part->channels == NULL) continue;
    for (int c = 0; c < NUM_CHANNELS; ++c) {
      sng_channel_t *channel = &part->channels[c];
      channel->bytes = calloc((channel->num_notes + 1), MAX_BYTES_PER_NOTE);
      int byte_index = 0;
      int last_duration = -1;
      for (int n = 0; n < channel->num_notes; ++n) {
        sng_note_t *note = &channel->notes[n];
        switch (note->kind) {
          case NOTE_REST: {
            int remaining_frames = note->frames;
            while (remaining_frames > 0) {
              int frames = remaining_frames < 127 ? remaining_frames : 127;
              channel->bytes[byte_index++] = frames;
              remaining_frames -= frames;
            }
          } break;
          case NOTE_INST:
            channel->bytes[byte_index++] = 0x80 | note->value;
            break;
          case NOTE_TONE: {
            int same = note->frames == last_duration;
            int bits = same ? 0xe0 : 0xc0;
            last_duration = note->frames;
            if (c == 3) {
              channel->bytes[byte_index++] = bits;
            } else {
              channel->bytes[byte_index++] = bits | (note->value >> 8);
              channel->bytes[byte_index++] = note->value & 0xff;
            }
            if (!same) {
              channel->bytes[byte_index++] = note->frames;
            }
          } break;
        }
      }
      channel->bytes[byte_index++] = 0;
      channel->num_bytes = byte_index;
    }
  }
}

/*===========================================================================*/

static void start_tone(int named_pitch, int flat_key, int sharp_key) {
  if (parser.current_channel < 0) {
    PARSE_ERROR("can't start tone before setting the channel\n");
  }
  parser.named_pitch = named_pitch;
  parser.base_pitch = named_pitch;
  if (parser.current_key <= flat_key) --parser.base_pitch;
  else if (parser.current_key >= sharp_key) ++parser.base_pitch;
  parser.pitch_adjust = 0;
  parser.state = ADJUST_PITCH;
}

static void start_base_duration(int denominator) {
  if (parser.frames_per_whole_note % denominator != 0) {
    PARSE_ERROR("can't emit 1/%d note with tempo of w=%d\n", denominator,
                parser.frames_per_whole_note);
  }
  parser.base_duration = parser.frames_per_whole_note / denominator;
  parser.state = ADJUST_DURATION;
}

static void adjust_base_duration(int numerator, int denominator) {
  int new_base_duration = parser.base_duration * numerator;
  if (new_base_duration % denominator != 0) {
    PARSE_ERROR("can't multiply note duration of %d frames by %d/%d\n",
                 parser.base_duration, numerator, denominator);
  }
  new_base_duration /= denominator;
  parser.base_duration = new_base_duration;
}

static sng_note_t *next_note(void) {
  assert(parser.num_songs > 0);
  sng_song_t *song = &parser.songs[parser.num_songs - 1];
  assert(parser.current_part >= 0);
  sng_part_t *part = &song->parts[parser.current_part];
  assert(parser.current_channel >= 0);
  sng_channel_t *channel = &part->channels[parser.current_channel];
  if (channel->notes == NULL) {
    channel->notes = calloc(MAX_NOTES_PER_CHANNEL, sizeof(sng_note_t));
  }
  if (channel->num_notes >= MAX_NOTES_PER_CHANNEL) {
    PARSE_ERROR("too many notes\n");
  }
  parser.state = NEW_NOTE;
  return &channel->notes[channel->num_notes++];
}

static void finish_tone(void) {
  sng_note_t *note = next_note();
  parser.base_duration += parser.extra_duration;
  parser.extra_duration = 0;
  if (parser.base_duration > 255) {
    PARSE_ERROR("note duration is too long (%d frames)\n",
                parser.base_duration);
  }
  note->frames = parser.base_duration;
  if (parser.named_pitch < 0) {
    note->kind = NOTE_REST;
  } else {
    note->kind = NOTE_TONE;
    const int absolute_pitch =
      parser.base_pitch + parser.pitch_adjust +
      HALF_STEPS_PER_OCTAVE * parser.octave;
    const double a4_relative_pitch = absolute_pitch - A4_PITCH;
    const double frequency =
      A4_FREQUENCY * pow(2.0, a4_relative_pitch / HALF_STEPS_PER_OCTAVE);
    const double value =
      2048.0 - (parser.current_channel == 2 ? 65536.0 : 131072.0) / frequency;
    note->value = round(fmin(fmax(0.0, value), 2047.0));
  }
}

/*===========================================================================*/

static void read_symbol(int ch) {
  while (next_char() == ' ') {}
  if (parser.current_char != ch) {
    PARSE_ERROR("expected '%c', not '%c'\n", ch, parser.current_char);
  }
  while (peek_char() == ' ') next_char();
}

static unsigned char read_hex_digit(void) {
  const int ch = next_char();
  if (ch >= '0' && ch <= '9') {
    return ch - '0';
  } else if (ch >= 'A' && ch <= 'F') {
    return 10 + ch - 'A';
  } else if (ch >= 'a' && ch <= 'f') {
    return 10 + ch - 'a';
  } else {
    PARSE_ERROR("invalid hex digit: '%c'\n", ch);
  }
}

static int read_unsigned_int(void) {
  int value = 0;
  int num_digits = 0;
  while (1) {
    const char ch = peek_char();
    if (ch < '0' || ch > '9') {
      if (num_digits == 0) {
        PARSE_ERROR("expected integer, not '%c'\n", ch);
      }
      return value;
    }
    next_char();
    ++num_digits;
    if (num_digits > MAX_INTEGER_DIGITS) {
      PARSE_ERROR("integer value is too large\n");
    }
    value = 10 * value + (ch - '0');
  }
}

static int read_signed_int(void) {
  int sign = 1;
  switch (next_char()) {
    case '+': sign = 1; break;
    case '-': sign = -1; break;
    default:
      PARSE_ERROR("invalid sign char: '%c'\n", parser.current_char);
  }
  return sign * read_unsigned_int();
}

/*===========================================================================*/

static void start_instrument(void) {
  if (parser.current_channel < 0) {
    PARSE_ERROR("can't start instrument before setting the channel\n");
  }
  parser.current_instrument.wave = -1;
  parser.current_instrument.envelope = -1;
  parser.current_instrument.effect = -1;
  parser.current_instrument.duty = -1;
  parser.state = INSTRUMENT;
}

static void parse_instrument_duty() {
  const int chan = parser.current_channel + 1;
  if (chan > 2) PARSE_ERROR("can't set duty on channel %d\n", chan);
  if (parser.current_instrument.duty != -1) {
    PARSE_ERROR("can't set duty twice in one instrument\n");
  }
  read_symbol('(');
  int numerator = read_unsigned_int();
  read_symbol('/');
  int denominator = read_unsigned_int();
  read_symbol(')');
  if (numerator == 1 && denominator == 8) {
    parser.current_instrument.duty = 0x00;
  } else if (numerator == 1 && denominator == 4) {
    parser.current_instrument.duty = 0x40;
  } else if (numerator == 1 && denominator == 2) {
    parser.current_instrument.duty = 0x80;
  } else if (numerator == 3 && denominator == 4) {
    parser.current_instrument.duty = 0xc0;
  } else {
    PARSE_ERROR("invalid duty: %d/%d\n", numerator, denominator);
  }
}

static void parse_instrument_envelope() {
  const int chan = parser.current_channel + 1;
  if (chan == 3) PARSE_ERROR("can't set envelope on channel %d\n", chan);
  if (parser.current_instrument.envelope != -1) {
    PARSE_ERROR("can't set envelope twice in one instrument\n");
  }
  read_symbol('(');
  int initial = read_unsigned_int();
  read_symbol(',');
  int shift = read_signed_int();
  read_symbol(')');
  if (initial > 15) PARSE_ERROR("invalid envelope init: %d\n", initial);
  if (shift < -7 || shift > 7) {
    PARSE_ERROR("invalid envelope shift: %d\n", initial);
  }
  parser.current_instrument.envelope =
    (initial << 4) | (shift < 0 ? shift & 7 : (-shift) & 15);
}

static void parse_instrument_level() {
  const int chan = parser.current_channel + 1;
  if (chan != 3) PARSE_ERROR("can't set level on channel %d\n", chan);
  if (parser.current_instrument.envelope != -1) {
    PARSE_ERROR("can't set level twice in one instrument\n");
  }
  read_symbol('(');
  int level = read_unsigned_int();
  read_symbol(')');
  if (level == 100) {
    parser.current_instrument.envelope = 0x20;
  } else if (level == 50) {
    parser.current_instrument.envelope = 0x40;
  } else if (level == 25) {
    parser.current_instrument.envelope = 0x60;
  } else if (level == 0) {
    parser.current_instrument.envelope = 0x00;
  } else {
    PARSE_ERROR("invalid level: %d\n", level);
  }
}

static void parse_instrument_poly() {
  const int chan = parser.current_channel + 1;
  if (chan != 4) PARSE_ERROR("can't set poly on channel %d\n", chan);
  if (parser.current_instrument.effect != -1) {
    PARSE_ERROR("can't set poly twice in one instrument\n");
  }
  PARSE_ERROR("TODO: parse_instrument_poly not implemented\n");
}

static void parse_instrument_sweep() {
  const int chan = parser.current_channel + 1;
  if (chan != 1) PARSE_ERROR("can't set sweep on channel %d\n", chan);
  if (parser.current_instrument.effect != -1) {
    PARSE_ERROR("can't set sweep twice in one instrument\n");
  }
  PARSE_ERROR("TODO: parse_instrument_sweep not implemented\n");
}

static void parse_instrument_wave() {
  const int chan = parser.current_channel + 1;
  if (chan != 3) PARSE_ERROR("can't set wave on channel %d\n", chan);
  if (parser.current_instrument.wave != -1) {
    PARSE_ERROR("can't set wave twice in one instrument\n");
  }
  read_symbol('(');
  sng_wave_t new_wave;
  for (int i = 0; i < BYTES_PER_WAVE; ++i) {
    unsigned char d1 = read_hex_digit();
    unsigned char d2 = read_hex_digit();
    new_wave.data[i] = (d1 << 4) | d2;
  }
  read_symbol(')');
  int wave_number = -1;
  for (int w = 0; w < parser.num_waves; ++w) {
    sng_wave_t *wave = &parser.waves[w];
    for (int i = 0; i < BYTES_PER_WAVE; ++i) {
      if (wave->data[i] != new_wave.data[i]) goto next_wave;
    }
    wave_number = w;
    break;
  next_wave:;
  }
  if (wave_number == -1) {
    if (parser.num_waves >= MAX_WAVES) {
      PARSE_ERROR("too many waves\n");
    }
    wave_number = parser.num_waves;
    parser.waves[parser.num_waves] = new_wave;
    ++parser.num_waves;
  }
  parser.current_instrument.wave = wave_number;
}

static void finish_instrument(void) {
  const int chan = parser.current_channel + 1;
  sng_instrument_t *curr = &parser.current_instrument;
  if (curr->envelope == -1) {
    if (chan == 3) curr->envelope = 0x20;
    else PARSE_ERROR("must set envelope on ch%d instrument\n", chan);
  }
  if (curr->effect == -1 && (chan == 1 || chan == 4)) curr->effect = 0x00;
  if (curr->duty == -1 && (chan == 1 || chan == 2)) curr->duty = 0x80;
  if (curr->wave == -1 && chan == 3) {
    PARSE_ERROR("must set wave on ch%d instrument\n", chan);
  }
  int inst_number = -1;
  for (int i = 0; i < parser.num_instruments; ++i) {
    sng_instrument_t *inst = &parser.instruments[i];
    if ((inst->envelope != -1 && curr->envelope != -1 &&
         inst->envelope != curr->envelope) ||
        (inst->effect != -1 && curr->effect != -1 &&
         inst->effect != curr->effect) ||
        ((inst->duty != -1 || inst->wave != -1) &&
         (curr->duty != -1 || curr->wave != -1) &&
         (inst->duty != curr->duty || inst->wave != curr->wave))) {
      continue;
    }
    if (inst->envelope == -1) inst->envelope = curr->envelope;
    if (inst->effect == -1) inst->effect = curr->effect;
    if (inst->duty == -1) inst->duty = curr->duty;
    if (inst->wave == -1) inst->wave = curr->wave;
    inst_number = i;
    break;
  }
  if (inst_number == -1) {
    if (parser.num_instruments >= MAX_INSTRUMENTS) {
      PARSE_ERROR("too many instruments\n");
    }
    inst_number = parser.num_instruments++;
    parser.instruments[inst_number] = parser.current_instrument;
  }
  sng_note_t *note = next_note();
  note->kind = NOTE_INST;
  note->value = inst_number;
}

/*===========================================================================*/

static void parse_key_directive(void) {
  int num_accidentals = read_unsigned_int();
  if (num_accidentals > 7) PARSE_ERROR("invalid key signature number\n");
  switch (next_char()) {
    case '#': parser.current_key = num_accidentals; break;
    case 'b': parser.current_key = -num_accidentals; break;
    case 'N': parser.current_key = 0; break;
    default: PARSE_ERROR("invalid key signature accidental\n");
  }
}

static void parse_tempo_directive(void) {
  int multiplier = 1;
  switch (next_char()) {
    case 'w': multiplier = 1; break;
    case 'h': multiplier = 2; break;
    case 'q': multiplier = 4; break;
    case 'e': multiplier = 8; break;
    case 's': multiplier = 16; break;
    case 't': multiplier = 32; break;
    case 'x': multiplier = 64; break;
    default: PARSE_ERROR("invalid tempo basis '%c'\n", parser.current_char);
  }
  int num_frames = read_unsigned_int();
  parser.frames_per_whole_note = multiplier * num_frames;
}

static void parse_directive(void) {
  switch (next_char()) {
    case 'k':
      if (next_char() != 'e') goto invalid;
      if (next_char() != 'y') goto invalid;
      if (next_char() != ' ') goto invalid;
      parse_key_directive();
      break;
    case 't':
      if (next_char() != 'e') goto invalid;
      if (next_char() != 'm') goto invalid;
      if (next_char() != 'p') goto invalid;
      if (next_char() != 'o') goto invalid;
      if (next_char() != ' ') goto invalid;
      parse_tempo_directive();
      break;
    default:
    invalid:
      PARSE_ERROR("invalid directive\n");
  }
  parser.state = AFTER_DECL_OR_DIR;
}

/*===========================================================================*/

static const char *read_quoted_string(void) {
  while (next_char() == ' ') {}
  if (parser.current_char != '"') {
    PARSE_ERROR("expected a quoted string\n");
  }
  int num_chars = 0;
  char buffer[MAX_QUOTED_STRING_CHARS + 1];
  while (next_char() != '"') {
    if (parser.current_char == EOF || parser.current_char == '\n') {
      PARSE_ERROR("unterminated quoted string\n");
    }
    if (num_chars >= MAX_QUOTED_STRING_CHARS) {
      PARSE_ERROR("quoted string is too long\n");
    }
    buffer[num_chars++] = parser.current_char;
  }
  buffer[num_chars] = '\0';
  return strdup(buffer);
}

static void parse_part_declaration(void) {
  if (parser.num_songs <= 0) {
    PARSE_ERROR("can't declare a part outside of a song\n");
  }
  sng_song_t *song = &parser.songs[parser.num_songs - 1];
  const char letter = next_char();
  if (letter < 'A' || letter > 'Z') {
    PARSE_ERROR("invalid part name: '%c'\n", letter);
  }
  const int part_number = letter - 'A';
  sng_part_t *part = &song->parts[part_number];
  if (part->channels != NULL) {
    PARSE_ERROR("reused part name: '%c'\n", letter);
  }
  part->channels = calloc(NUM_CHANNELS, sizeof(sng_channel_t));
  part->index = -1;
  parser.current_part = part_number;
  parser.current_channel = -1;
}

static void parse_song_declaration(void) {
  if (parser.num_songs == MAX_SONGS_PER_FILE) {
    PARSE_ERROR("too many songs in one file\n");
  }
  finish_current_song();
  sng_song_t* song = &parser.songs[parser.num_songs++];
  song->title = read_quoted_string();
  song->spec = read_quoted_string();
  song->parts = calloc(MAX_PARTS_PER_SONG, sizeof(sng_part_t));
  parser.current_part = -1;
  parser.current_channel = -1;
}

static void parse_declaration(void) {
  switch (next_char()) {
    case 'P':
      if (next_char() != 'A') goto invalid;
      if (next_char() != 'R') goto invalid;
      if (next_char() != 'T') goto invalid;
      if (next_char() != ' ') goto invalid;
      parse_part_declaration();
      break;
    case 'S':
      if (next_char() != 'O') goto invalid;
      if (next_char() != 'N') goto invalid;
      if (next_char() != 'G') goto invalid;
      if (next_char() != ' ') goto invalid;
      parse_song_declaration();
      break;
    default:
    invalid:
      PARSE_ERROR("invalid declaration\n");
  }
  parser.state = AFTER_DECL_OR_DIR;
}

/*===========================================================================*/

static void parse_input(void) {
  init_parser();
  while (1) {
    const char ch = next_char();
    switch (parser.state) {
      case BEGIN_LINE:
        switch (ch) {
          case '%': parser.state = LINE_COMMENT; break;
          case ' ': parser.state = NEW_NOTE; break;
          case '!': parse_declaration(); break;
          case '=': parse_directive(); break;
          case '1': case '2': case '3': case '4':
            if (parser.current_part < 0) {
              PARSE_ERROR("can't set channel outside of a part\n");
            }
            parser.current_channel = ch - '1';
            parser.state = NEW_NOTE;
            break;
          case '\n': begin_line(); break;
          case EOF: goto eof;
          default: PARSE_ERROR("invalid char at start-of-line: '%c'\n", ch);
        }
        break;
      case NEW_NOTE:
        switch (ch) {
          case '%': parser.state = LINE_COMMENT; break;
          case 'a': start_tone( 9, -3, 5); break;
          case 'b': start_tone(11, -1, 7); break;
          case 'c': start_tone( 0, -6, 2); break;
          case 'd': start_tone( 2, -4, 4); break;
          case 'e': start_tone( 4, -2, 6); break;
          case 'f': start_tone( 5, -7, 1); break;
          case 'g': start_tone( 7, -5, 3); break;
          case 'r': start_tone(-1, -9, 9); break;
          case '{': start_instrument(); break;
          case ' ': case '|': case '\'': break;
          case '\n': begin_line(); break;
          case EOF: goto eof;
          default: PARSE_ERROR("invalid char at start-of-note: '%c'\n", ch);
        }
        break;
      case ADJUST_PITCH:
        switch (ch) {
          case '%': finish_tone(); parser.state = LINE_COMMENT; break;
          case '#':
            parser.base_pitch = parser.named_pitch;
            ++parser.pitch_adjust;
            break;
          case 'b':
            parser.base_pitch = parser.named_pitch;
            --parser.pitch_adjust;
            break;
          case 'N':
            parser.base_pitch = parser.named_pitch;
            parser.pitch_adjust = 0;
            break;
          case '0': case '1': case '2': case '3': case '4':
          case '5': case '6': case '7': case '8': case '9':
            parser.octave = ch - '0';
            parser.state = BEGIN_DURATION;
            break;
          case 'w': case 'h': case 'q': case 'e':
          case 's': case 't': case 'x':
            goto begin_duration;
          case ' ': case '|': case '\'':
            finish_tone();
            break;
          case '\n':
            finish_tone();
            begin_line();
            break;
          case EOF:
            finish_tone();
            goto eof;
          default: PARSE_ERROR("invalid char within note: '%c'\n", ch);
        }
        break;
      case CONTINUE_DURATION:
        switch (ch) {
          case 'w': case 'h': case 'q': case 'e':
          case 's': case 't': case 'x':
            goto begin_duration;
          case '+': break;
          case ' ': case '|': case '\'': break;
          default:
            PARSE_ERROR("invalid duration continuation char: '%c'\n", ch);
        }
        break;
      case BEGIN_DURATION:
      begin_duration:
        switch (ch) {
          case 'w': start_base_duration(1); break;
          case 'h': start_base_duration(2); break;
          case 'q': start_base_duration(4); break;
          case 'e': start_base_duration(8); break;
          case 's': start_base_duration(16); break;
          case 't': start_base_duration(32); break;
          case 'x': start_base_duration(64); break;
          case ' ': case '|': case '\'':
            finish_tone();
            break;
          case '\n':
            finish_tone();
            begin_line();
            break;
          case EOF:
            finish_tone();
            goto eof;
          default:
            PARSE_ERROR("invalid duration char: '%c'\n", ch);
        }
        break;
      case ADJUST_DURATION:
        switch (ch) {
          case '.':
            parser.extra_duration += parser.base_duration;
            adjust_base_duration(1, 2);
            break;
          case '3': adjust_base_duration(2, 3); break;
          case '5': adjust_base_duration(4, 5); break;
          case '+':
            parser.extra_duration += parser.base_duration;
            parser.base_duration = 0;
            parser.state = CONTINUE_DURATION;
            break;
          case ' ': case '|': case '\'':
            finish_tone();
            break;
          case '\n':
            finish_tone();
            begin_line();
            break;
          case EOF:
            finish_tone();
            goto eof;
          default:
            PARSE_ERROR("invalid duration adjustment char: '%c'\n", ch);
        }
        break;
      case INSTRUMENT:
        switch (ch) {
          case 'D': parse_instrument_duty(); break;
          case 'E': parse_instrument_envelope(); break;
          case 'L': parse_instrument_level(); break;
          case 'P': parse_instrument_poly(); break;
          case 'S': parse_instrument_sweep(); break;
          case 'W': parse_instrument_wave(); break;
          case '}': finish_instrument(); break;
          case ' ': break;
          case '%': case '\n': case EOF:
            PARSE_ERROR("unterminated instrument\n");
          default:
            PARSE_ERROR("invalid char in instrument: '%c'\n", ch);
        }
        break;
      case AFTER_DECL_OR_DIR:
        switch (ch) {
          case '%': parser.state = LINE_COMMENT; break;
          case ' ': break;
          case '\n': begin_line(); break;
          case EOF: goto eof;
          default:
            PARSE_ERROR("invalid char after declaration/directive: '%c'\n",
                        ch);
        }
        break;
      case LINE_COMMENT:
        switch (ch) {
          case '\n': begin_line(); break;
          case EOF: goto eof;
          default: break;
        }
        break;
    }
  }
 eof:
  finish_current_song();
}

/*===========================================================================*/

static char *strprintf(const char *format, ...) {
  va_list args;
  va_start(args, format);
  const size_t size = vsnprintf(NULL, 0, format, args);
  va_end(args);
  char *out = calloc(size + 1, sizeof(char)); // add 1 for trailing '\0'
  va_start(args, format);
  vsprintf(out, format, args);
  va_end(args);
  return out;
}

int channels_match(sng_channel_t *channel, sng_channel_t *other) {
  if (channel->num_bytes != other->num_bytes) return 0;
  for (int b = 0; b < channel->num_bytes; ++b) {
    if (channel->bytes[b] != other->bytes[b]) return 0;
  }
  return 1;
}

sng_sequence_t *matching_sequence(sng_channel_t *channel) {
  for (int q = 0; q < parser.num_sequences; ++q) {
    sng_sequence_t *sequence = &parser.sequences[q];
    if (channels_match(channel, sequence->channel)) return sequence;
  }
  return NULL;
}

static void generate_sequences(void) {
  // Init sequence array:
  int total_num_channels = 0;
  for (int s = 0; s < parser.num_songs; ++s) {
    sng_song_t *song = &parser.songs[s];
    for (int p = 0; p < MAX_PARTS_PER_SONG; ++p) {
      sng_part_t *part = &song->parts[p];
      if (part->channels == NULL) continue;
      total_num_channels += NUM_CHANNELS;
    }
  }
  parser.sequences = calloc(total_num_channels, sizeof(sng_sequence_t));
  // Generate or reuse a sequence for each channel:
  for (int s = 0; s < parser.num_songs; ++s) {
    sng_song_t *song = &parser.songs[s];
    for (int p = 0; p < MAX_PARTS_PER_SONG; ++p) {
      sng_part_t *part = &song->parts[p];
      if (part->channels == NULL) continue;
      for (int c = 0; c < NUM_CHANNELS; ++c) {
        sng_channel_t *channel = &part->channels[c];
        sng_sequence_t *sequence = matching_sequence(channel);
        if (sequence == NULL) {
          sequence = &parser.sequences[parser.num_sequences++];
          sequence->channel = channel;
          sequence->labels = calloc(total_num_channels, sizeof(char*));
        }
        sequence->labels[sequence->num_labels++] =
          strprintf("_%s_P%02dch%d", song->title, part->index, c + 1);
      }
    }
  }
}

/*===========================================================================*/

static void write_output(void) {
  // Write file header:
  fprintf(stdout, ";;; This file was generated by sng2asm.\n");
  if (parser.num_songs == 0) return;
  const char *section_name = parser.songs[0].title;
  fprintf(stdout, "\nSECTION \"%s\", ROM0\n", section_name);
  // Write song structs:
  for (int s = 0; s < parser.num_songs; ++s) {
    sng_song_t *song = &parser.songs[s];
    fprintf(stdout, "\nData_%s_song::\n", song->title);
    fprintf(stdout, "    DW _%s_InstTable, .sectTable", section_name);
    for (int o = 0; o < song->num_opcodes; ++o) {
      int opcode = song->opcodes[o];
      if (o % 14 == 0) {
        fprintf(stdout, "\n    DB $%02x", opcode);
      } else {
        fprintf(stdout, ", $%02x", opcode);
      }
    }
    fprintf(stdout, "\n    .sectTable\n");
    for (int p = 0; p < MAX_PARTS_PER_SONG; ++p) {
      sng_part_t *part = &song->parts[p];
      if (part->channels == NULL) continue;
      fprintf(stdout, "    DW _%s_P%02dch1, _%s_P%02dch2\n", song->title,
              part->index, song->title, part->index);
      fprintf(stdout, "    DW _%s_P%02dch3, _%s_P%02dch4\n", song->title,
              part->index, song->title, part->index);
    }
  }
  // Write instrument table:
  fprintf(stdout, "\n_%s_InstTable:\n", section_name);
  for (int i = 0; i < parser.num_instruments; ++i) {
    sng_instrument_t *inst = &parser.instruments[i];
    int b1 = inst->envelope != -1 ? inst->envelope : 0;
    int b2 = inst->effect != -1 ? inst->effect : 0;
    fprintf(stdout, "    DW $%02x%02x, ", b2, b1);
    if (inst->wave != -1) {
      fprintf(stdout, ".wave%d\n", inst->wave);
    } else {
      fprintf(stdout, "$00%02x\n", inst->duty != -1 ? inst->duty : 0);
    }
  }
  for (int w = 0; w < parser.num_waves; ++w) {
    sng_wave_t *wave = &parser.waves[w];
    fprintf(stdout, "    .wave%d", w);
    for (int b = 0; b < BYTES_PER_WAVE; ++b) {
      int byte = wave->data[b];
      if (b % (BYTES_PER_WAVE / 2) == 0) {
        fprintf(stdout, "\n    DB $%02x", byte);
      } else {
        fprintf(stdout, ", $%02x", byte);
      }
    }
    fprintf(stdout, "\n");
  }
  // Write note sequences:
  fprintf(stdout, "\n");
  for (int q = 0; q < parser.num_sequences; ++q) {
    sng_sequence_t *sequence = &parser.sequences[q];
    for (int i = 0; i < sequence->num_labels; ++i) {
      fprintf(stdout, "\n%s:", sequence->labels[i]);
    }
    sng_channel_t *channel = sequence->channel;
    for (int b = 0; b < channel->num_bytes; ++b) {
      int byte = channel->bytes[b];
      if (b % 14 == 0) {
        fprintf(stdout, "\n    DB $%02x", byte);
      } else {
        fprintf(stdout, ", $%02x", byte);
      }
    }
    fprintf(stdout, "\n");
  }
}

/*===========================================================================*/

int main(int argc, char **argv) {
  parse_input();
  generate_sequences();
  write_output();
  return EXIT_SUCCESS;
}

/*===========================================================================*/
