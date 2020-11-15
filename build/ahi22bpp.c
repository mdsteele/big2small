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

int main(int argc, char **argv) {
  int width, height, count;
  if (fscanf(stdin, "ahi0 w%u h%u n%u", &width, &height, &count) != 3) {
    fprintf(stderr, "Invalid header\n");
    return EXIT_FAILURE;
  }
  if (width % 8 != 0 || height % 8 != 0) {
    fprintf(stderr, "Invalid size: %dx%d\n", width, height);
    return EXIT_FAILURE;
  }
  if (!read_newline()) return EXIT_FAILURE;
  int horz_tiles = width / 8;
  unsigned char *buffer = malloc(width * height);
  for (int n = 0; n < count; ++n) {
    if (!read_newline()) return EXIT_FAILURE;
    for (int pixel_row = 0; pixel_row < height; ++pixel_row) {
      for (int pixel_col = 0; pixel_col < width; ++pixel_col) {
        int ch = fgetc(stdin);
        int pixel;
        if (ch >= '0' && ch <= '9') {
          pixel = ch - '0';
        } else if (ch >= 'a' && ch <= 'f') {
          pixel = ch - 'a' + 0xa;
        } else if (ch >= 'A' && ch <= 'F') {
          pixel = ch - 'A' + 0xA;
        } else {
          fprintf(stderr, "Invalid pixel char: 0x%x\n", ch);
          return EXIT_FAILURE;
        }
        buffer[pixel_row * width + pixel_col] = pixel % 4;
      }
      if (!read_newline()) return EXIT_FAILURE;
    }
    for (int tile_col = 0; tile_col < horz_tiles; ++tile_col) {
      for (int pixel_row = 0; pixel_row < height; ++pixel_row) {
        unsigned char byte1 = 0, byte2 = 0;
        for (int pixel_col = 0; pixel_col < 8; ++pixel_col) {
          unsigned char pixel =
            buffer[pixel_row * width + 8 * tile_col + pixel_col];
          byte1 = (byte1 << 1) | (pixel & 1);
          byte2 = (byte2 << 1) | ((pixel >> 1) & 1);
        }
        fputc(byte1, stdout);
        fputc(byte2, stdout);
      }
    }
  }
  return EXIT_SUCCESS;
}

/*===========================================================================*/
