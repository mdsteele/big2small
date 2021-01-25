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

#include <stdio.h>
#include <stdlib.h>

/*===========================================================================*/

int read_newline(void) {
  int ch = fgetc(stdin);
  if (ch != '\n') {
    fprintf(stderr, "Expected newline, got 0x%x\n", ch);
    return 0;
  }
  return 1;
}

int from_base64(int ch) {
  if (ch >= 'A' && ch <= 'Z') {
    return ch - 'A';
  } else if (ch >= 'a' && ch <= 'z') {
    return ch - 'a' + 26;
  } else if (ch >= '0' && ch <= '9') {
    return ch - '0' + 52;
  } else if (ch == '+') {
    return 62;
  } else if (ch == '/') {
    return 63;
  } else {
    return -1;
  }
}

int main(int argc, char **argv) {
  // Read header:
  int width, height;
  if (fscanf(stdin, "@BG 255 255 255 %ux%u", &width, &height) != 2) {
    fprintf(stderr, "Invalid header\n");
    return EXIT_FAILURE;
  }
  if (width <= 0 || height <= 0) {
    fprintf(stderr, "Invalid size: %dx%d\n", width, height);
    return EXIT_FAILURE;
  }
  if (!read_newline()) return EXIT_FAILURE;

  // Skip tilesets:
  for (int on_tileset = 1; on_tileset;) {
    on_tileset = 0;
    while (1) {
      int ch = fgetc(stdin);
      if (ch == '\n' || ch == EOF) {
        break;
      }
      on_tileset = 1;
    }
  }

  // Read grid:
  for (int row = 0; row < height; ++row) {
    for (int col = 0; col < width; ++col) {
      int ch = fgetc(stdin);
      if (ch == '\n' || ch == EOF) {
        goto end_row;
      }
      int value1 = from_base64(ch);
      int value2 = from_base64(fgetc(stdin));
      if (value1 < 0 || value2 < 0) {
        fputc(0x00, stdout);
      } else if (value1 == 0) {
        fputc(0x80 + value2, stdout);
      } else if (value1 == 1) {
        fputc(0xE0 + value2, stdout);
      }
    }
    if (!read_newline()) return EXIT_FAILURE;
  end_row:;
  }
  return EXIT_SUCCESS;
}

/*===========================================================================*/
