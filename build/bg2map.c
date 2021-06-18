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
#include <string.h>

/*===========================================================================*/

#define MAX_TILESETS 64

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

char *read_tileset(void) {
  int ch = fgetc(stdin);
  if (ch == '\n') return NULL;
  int index = 0;
  char buffer[80] = {0};
  while (index + 1 < sizeof(buffer)) {
    ch = fgetc(stdin);
    if (ch == EOF || ch == '\n') break;
    buffer[index++] = ch;
  }
  return strcpy(calloc(index + 1, sizeof(char)), buffer);
}

/*===========================================================================*/

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

  // Read tilesets:
  char *tilesets[MAX_TILESETS] = {0};
  int num_tilesets = 0;
  while (1) {
    char *tileset = read_tileset();
    if (tileset == NULL) break;
    if (num_tilesets >= MAX_TILESETS) {
      fprintf(stderr, "too many tilesets\n");
      return EXIT_FAILURE;
    }
    tilesets[num_tilesets++] = tileset;
  }

  // Read grid:
  for (int row = 0; row < height; ++row) {
    for (int col = 0; col < width; ++col) {
      int ch = fgetc(stdin);
      if (ch == '\n' || ch == EOF) {
        for (; col < width; ++col) {
          fputc(0x00, stdout);
        }
        goto end_row;
      }
      int tileset_index = from_base64(ch);
      if (tileset_index >= num_tilesets) {
        fprintf(stderr, "tileset index %d out of range\n", tileset_index);
        return EXIT_FAILURE;
      }
      const char *tileset = tilesets[tileset_index];
      int tile_index = from_base64(fgetc(stdin));
      if (tileset_index < 0 || tile_index < 0) {
        fputc(0x00, stdout);
      } else if (0 == strcmp(tileset, "ocean") ||
                 0 == strcmp(tileset, "twinkle")) {
        fputc(0x68, stdout);
      } else if (0 == strcmp(tileset, "map_barn")) {
        fputc(0xd0 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_brick")) {
        fputc(0xd0 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_bridge")) {
        fputc(0x98 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_earth")) {
        fputc(0xd0 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_fence")) {
        fputc(0x90 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_launch")) {
        fputc(0xc0 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_mountain")) {
        fputc(0xa0 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_office")) {
        fputc(0xd0 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_pipe")) {
        fputc(0xc0 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_river")) {
        fputc(0xf0 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_ship")) {
        fputc(0xd8 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_silo")) {
        fputc(0xc0 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_skyline")) {
        fputc(0xe0 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_stars")) {
        fputc(0xfc + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_station")) {
        fputc(0xc0 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_trail")) {
        fputc(0x80 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "map_tree")) {
        fputc(0xb0 + tile_index, stdout);
      } else if (0 == strcmp(tileset, "river")) {
        fputc(0xe0 + tile_index, stdout);
      } else {
        fprintf(stderr, "unknown tileset: %s\n", tileset);
        return EXIT_FAILURE;
      }
    }
    if (!read_newline()) return EXIT_FAILURE;
  end_row:;
  }
  return EXIT_SUCCESS;
}

/*===========================================================================*/
