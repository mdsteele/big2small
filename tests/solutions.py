#=============================================================================#
# Copyright 2020 Matthew D. Steele <mdsteele@alum.mit.edu>                    #
#                                                                             #
# This file is part of Big2Small.                                             #
#                                                                             #
# Big2Small is free software: you can redistribute it and/or modify it under  #
# the terms of the GNU General Public License as published by the Free        #
# Software Foundation, either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# Big2Small is distributed in the hope that it will be useful, but WITHOUT    #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or       #
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for   #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU General Public License along     #
# with Big2Small.  If not, see <http://www.gnu.org/licenses/>.                #
#=============================================================================#

from __future__ import print_function

import re

#=============================================================================#

SOLUTIONS = {
    'Forest0': 'Eene',
    'Forest1': 'EnGnwneEe',
    'Forest2': 'GnwMseEwneGswMnwswGnenws',
    'Forest3': 'GenEeMneEseGwswsMseswGnEwsenMesese',
    'Forest4': 'GeswnesnMenGwswMwswGsewEwnwsGeMnEwMsGwMnEneMenws',
    'ForestBonus': ('GesnMsEwGsesEeGnenEsMneEnesMsGswsenenwseMneswseGswswMnGe'
                    'MswnwseEw'),
    'Forest6': 'EnMeneswswnwseGeswsMwsenGnenwEwsGeseMesenEesenGwsMeswsGwnwswn',
    'Farm0': 'MenwsEenMwEsMenwEnwMseswnenGnwsMeGnMwsGeMnGwsMeswn',
    'Farm1': 'GnweMeEswnMwnenwGwseneswnwswneneMeGswneMswneEsenw',
    'Farm2': ('MeswsenGswnwMswneEneGnenMswEwsGswswswnMenwswswneGeneneEnene'
              'Gwsen'),
    'FarmBonus': ('MesEneseswseGwseMwneswneEnenwMnwsEenwswsMwnwnwsenwEnwsenw'
                  'MswnesGswnese'),
    'Farm4': 'EseneMswnEwsMwswnEwneGwneEsenMeseneEesenMws',
    'Mountain0': 'GeMeeseeEweseeMsswGesswwnesMenes',
    'Lake0': 'GsenwMsGeEsenwMnwneEsMwEneswGwsMeswswnGwnwsMsesGesEs',
    'Lake1': 'EneGnwswnMwneEswnGesMwnesGwseneswnwMwseneswsw',
    'LakeBonus': 'MseswnGnenwEwswGseswnwseMsGwMneseswsenGenMswnEws',
    'Lake3': 'GwsEsMwnwswwsGwwswnesMnGewwMsGsMnEwnwesGeMwne',
    'Lake4': ('GneMswnwEswGwsesMeswEnGeMseGwnwMnwnEwsGeMsGwneEneMsenenEwse'
              'MnwswseEe'),
    'Sewer0': ('GnEwsesenGesesenEenwGswEeMsEwswnGenEeneMnGwEwsesGesMwseEwsen'
               'Mnw'),
    'Sewer1': 'MnEessGsEnwGsweEeswswewnGwwwEsensweMsenwse',
    'SewerBonus': ('EwGwsesEeneGnewnEsGeEnewnwnGwEseneseeMnwneseGneseeneses'
                   'EswGnwnwseEenesesweswMwnwswsEnwswswnwnGwswnwEseGnMnwne'
                   'EwneMswsesGseswMnwneseenese'),
    'City0': ('EwsGesenMenEnGeneMeneGsEeswMseGwEnwsGeneEnGwEwnwseGnEwGseEnGwEs'
              'GeEeswMs'),
    'City1': 'GwenwseMwseEwsGneEesenMsGwEwMenwGnesenwsMeGnMwGsenw',
    'City2': ('EeGneMnwsenesenwnEwnesenwMswswEnwswnewseseGwMnGeseMeEswGnwsEs'
              'GeEnwn'),
    'CityBonus': 'GeswneMneGswnEeMnesGeMnwEnwGnMneseGeswMnwsesGnMwnGeswnMw',
    'City4': ('GneseEswnwswsenesMsseEwnMneneGwEsenweGeMsenwEswsGwEnesGwnesEe'
              'MesEwnwssw'),
    'Space0': 'GeswnMswGesMesEsenGnwsenwMwnEswnGeMen',
}

#=============================================================================#

RE_PUZZ_LABEL = re.compile(r'^DataX_([a-zA-Z0-9_]+)_puzz:$', re.MULTILINE)
RE_TERRAIN_ROW = re.compile(
    r'^ *DB (.*)(?:\n.*(?:0|\$([0-9])([0-9])), (?:0|\$([0-9])([0-9])))?$',
    re.MULTILINE)
RE_ANIM = re.compile('D_ANIM \$([0-9a-f])([0-9a-f]),')
RE_PAR = re.compile('D_PAR \$([0-9]{4})')
RE_ASSERT = re.compile(r'ASSERT')

def load_puzzles():
    puzzles = {}
    asm = open('src/puzzdata.asm').read()
    for label_match in RE_PUZZ_LABEL.finditer(asm):
        puzz_name = label_match.group(1)
        start = label_match.end()
        end = RE_ASSERT.search(asm, start).start()
        terrain_grid = []
        teleport = {}
        for (y, match) in enumerate(RE_TERRAIN_ROW.finditer(asm, start, end)):
            terrain_row = match.group(1).split(', ')
            assert len(terrain_row) == 10
            terrain_grid.append(terrain_row)
            if match.group(2) is not None:
                teleport[(y, 'E')] = (int(match.group(2)), int(match.group(3)))
            if match.group(4) is not None:
                teleport[(y, 'F')] = (int(match.group(4)), int(match.group(5)))
        assert len(terrain_grid) == 9
        animals = [(int(match.group(1), 16), int(match.group(2), 16)) for
                   match in RE_ANIM.finditer(asm, start, end)]
        assert len(animals) == 3, (puzz_name, animals)
        puzzles[puzz_name] = {
            'animals': animals,
            'par': int(RE_PAR.search(asm, start, end).group(1)),
            'terrain': terrain_grid,
            'teleport': teleport,
        }
    return puzzles

#=============================================================================#

ELEPHANT = 0
GOAT = 1
MOUSE = 2

def check_on_goal(position, terrain, goal):
    if position[1] < 10 and terrain[position] != goal:
        raise RuntimeError('ended on {} at {} instead of {}'
                           .format(terrain[position], position, goal))

def apply_direction(position, direction):
    if direction == 'n': return (position[0] - 1, position[1])
    elif direction == 's': return (position[0] + 1, position[1])
    elif direction == 'e': return (position[0], position[1] + 1)
    elif direction == 'w': return (position[0], position[1] - 1)
    else: raise ValueError('invalid direction: {}'.format(direction))

def is_blocked(position, direction, current_animal, animals, terrain,
               allow_jump=True):
    if (position[0] < 0 or position[0] > 8 or
        position[1] < 0 or position[1] > 9):
        return True
    if any(pos == position for pos in animals): return True
    tile = terrain[position]
    if tile.startswith('W_'): return True
    if tile.startswith('M_') and current_animal != MOUSE: return True
    if tile.startswith('R_'):
        if current_animal != GOAT or not allow_jump: return True
        return is_blocked(apply_direction(position, direction), direction,
                          GOAT, animals, terrain, allow_jump=False)
    if tile == 'S_BSH': return current_animal != GOAT
    if tile == 'S_PPW':
        return (current_animal != ELEPHANT or direction != 'e' or
                is_blocked((position[0], position[1] + 2), 'e', ELEPHANT,
                           animals, terrain))
    if tile == 'S_PPE':
        return (current_animal != ELEPHANT or direction != 'w' or
                is_blocked((position[0], position[1] - 2), 'w', ELEPHANT,
                           animals, terrain))
    return False

def make_move(direction, current_animal, animals, terrain, teleport):
    while True:
        position = apply_direction(animals[current_animal], direction)
        if is_blocked(position, direction, current_animal, animals, terrain):
            return
        animals[current_animal] = position
        tile = terrain[position]
        if tile == 'S_BSH': terrain[position] = 'O_BST'
        elif tile == 'S_ARN': direction = 'n'
        elif tile == 'S_ARS': direction = 's'
        elif tile == 'S_ARE': direction = 'e'
        elif tile == 'S_ARW': direction = 'w'
        elif tile == 'S_PPW':
            terrain[position] = 'O_EMP'
            terrain[(position[0], position[1] + 2)] = 'S_PPE'
        elif tile == 'S_PPE':
            terrain[position] = 'O_EMP'
            terrain[(position[0], position[1] - 2)] = 'S_PPW'
        elif tile == 'S_MTP' and current_animal == MOUSE:
            raise RuntimeError('mouse hit mousetrap at {}'.format(position))
        elif (tile == 'S_TGE' and current_animal == GOAT or
              tile == 'S_TME' and current_animal == MOUSE):
            animals[current_animal] = teleport[(position[0], 'E')]
        elif (tile == 'S_TEF' and current_animal == ELEPHANT or
              tile == 'S_TMF' and current_animal == MOUSE):
            animals[current_animal] = teleport[(position[0], 'F')]

def test_solution(puzzle, solution):
    animals = list(puzzle['animals'])
    terrain = {(row, col): tile for
               (row, tiles) in enumerate(puzzle['terrain']) for
               (col, tile) in enumerate(tiles)}
    teleport = puzzle['teleport']
    current_animal = ELEPHANT
    num_moves = 0
    for char in solution:
        if char == ' ': pass
        elif char == 'E': current_animal = ELEPHANT
        elif char == 'G': current_animal = GOAT
        elif char == 'M': current_animal = MOUSE
        else:
            make_move(char, current_animal, animals, terrain, teleport)
            num_moves += 1
    check_on_goal(animals[ELEPHANT], terrain, 'G_PNT')
    check_on_goal(animals[GOAT], terrain, 'G_APL')
    check_on_goal(animals[MOUSE], terrain, 'G_CHS')
    if num_moves != puzzle['par']:
        raise RuntimeError('solved puzzle in {} moves, but par is {}'
                           .format(num_moves, puzzle['par']))

#=============================================================================#

if __name__ == '__main__':
    puzzles = load_puzzles()
    num_passed = 0
    num_failed = 0
    for (name, solution) in SOLUTIONS.iteritems():
        try:
            if name not in puzzles: raise RuntimeError('no such puzzle')
            test_solution(puzzles[name], solution)
        except RuntimeError as err:
            print('FAILED: {}: {}'.format(name, err))
            num_failed += 1
        else: num_passed += 1
    print('{} passed, {} failed'.format(num_passed, num_failed))

#=============================================================================#
