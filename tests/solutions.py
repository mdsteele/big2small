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

import collections
import re
import sys

#=============================================================================#

SOLUTIONS = [
    ('Forest0', 0, 'Eene'),
    ('Forest1', 0, 'EnGnwneEe'),
    ('Forest2', 0, 'EwnesGwMseGnMwEwGwMws'),
    ('Forest3', 0, 'GenEeMneEseGwswMseswEwGsMwGnMesese'),
    ('Forest3', 1, 'MnEesMeGeMsEwGseMwGswEswGswMesGeMese'),
    ('Forest4', 0, 'GeswnesnMenGwswMwswGseMnGwEwnwsGnesEwneMenws'),
    ('ForestBonus', 0,
     'GesnMsEwGsesEeGnenEsMneEnesMsGswsenenwseMneswseGswswMnGeMswnwseEw'),
    ('ForestBonus', 1,
     'GesnMsEwGseEesMneGswnenEnesMnGswseneneswMsGswMeswsenGeMswnwseEw'),
    ('Forest6', 0,
     'EnMeneswswnwseGeswsMwsenGnenwEwsGeseMesenEesenGwsMeswsGwnwswn'),
    ('Forest6', 4,
     'GeMnEwneswswnwseGswsEwnenGnenwMsGesenMeEesenwGswsMsGwnwswn'),
    ('Farm0', -5, 'MenwsEenMwEsMenwEnwMseswnenGnwsMeGnMwsGeMnGwsMeswn'),
    ('Farm0', -1, 'MenwsEenMwEsMenwEnwMseswneGnwMnwGseMeGnwseMn'),
    ('Farm0', 0, 'MenwsEenMwEsMenwEnwMseswneneGwnMswnGwseMn'),
    ('Farm1', 0, 'GnweMeEswnMwnenwGwseneswnwswneneMeGswneMswneEsenw'),
    ('Farm2', 0, 'MeswsenGswnwnEwneGsEwGnwswnMswneEneGenenenEwGseEeneGwsen'),
    ('Farm2', 3, 'MeswsenGswnwnEwneGsEwGnEneGwsMswGwneMnGnenenswsenEwne'),
    ('FarmBonus', 0,
     'MesEneseswseGwseMwneswneEnenwMnwsEenwswsMwnwnwsenwEnwsenwMswnesGswnese'),
    ('FarmBonus', 5,
     'GwseMesEneMnesEseswMnwsEswsGwEnenwswsMwnwnwsenwEnwsenwMswnesGswnese'),
    ('Farm4', 0, 'EseneMswnEwsMwswnEwneGwneEsenMeseneEesenMws'),
    ('Mountain0', 0, 'GeMeeseeEweseeMsswGesswwnesMenes'),
    ('Mountain0', 1, 'EsseGeMeeseGeEseMwswGsswwnesMenes'),
    ('Mountain1', 0, 'EwMwGswMnEenGnnewEeswMsEeGeMeeGnwEwnwGsenwsMsn'),
    ('Mountain1', 3, 'EwGswMwGnEenMnnEeseGseseMeeGnwEwnMsnEwGseMn'),
    ('MountainBonusA', 0,
     'MnEwneswwMsesGwsenEeMnwsGwseseMeneseEwGnEeseMwnGswnEwnMesGnMwwGsEsew'
     'MnesEwnesMwneses'),
    ('MountainBonusA', 9,
     'EwneswGswMnEwMsEsMesGenwseMnwsEeneseMeGsMsGwnMnEwnMwGsEseMwEwMnesEwnes'
     'Mwneses'),
    ('Mountain3', -13,
     'GeMeswseGnwsenMenwswGeswsnGenwsMenEsenesMwEnGwnMeGeenEeMeEswnesMesEe'
     'Mnwswne'),
    ('Mountain3', 0,
     'EseGeMeswGnwnMenwswnGwsMeGneEnesGwEnGeEsMsEeMnwswneGswnesenMe'),
    ('MountainBonusB', 0,
     'EwMsenGsenewwMwwGenesewswseEewMwsenwEswsMewswneGnweEenweenwMwwGwMen'
     'Gwsen'),
    ('MountainBonusB', 7,
     'GsenewMsGwMenwwGenwsEwseGewMwsenwGswseEnMewswGnweEweenwMwGwMwsenGen'),
    ('Mountain5', 0,
     'MwwGneswseMnwseeGnenEnwseenMwnenseGeswEseswswGsesEsenGn'),
    ('Mountain5', 11, 'MsGneswMwseGseMnwGeEnGwEwseGsEeMenEnMseneEswsenGn'),
    ('Lake0', 0, 'GsEsenwsGeMswnEeGswEswGesMswnGwnwsMsesGesEs'),
    ('Lake0', 3, 'EesGseMswsGwsMeswswsEenGnEeswneswsGs'),
    ('Lake1', 0, 'EneGnwswnMwneEswnGesMwnesGwseneswnwMwseneswsw'),
    ('Lake1', 8, 'GwswsewMwGnEwGeEneGwEnwseMseneEswnMeswsw'),
    ('LakeBonus', 0, 'MseswnGnenwEwswGseswnwseMsGwMneseswsenGenMswnEws'),
    ('LakeBonus', 2, 'MesGnenwMnwGseEwswMwsGwMnesGsewnMeswsenGeMswnGnEws'),
    ('Lake3', 0, 'GwsEsMwnwswwsGwwswnesMnGewwMsGsMnEwnwesGeMwne'),
    ('Lake3', 6, 'MwEsGwMnGsMwGwMswsGwsswneseEwMneEnMwneGws'),
    ('Lake4', 0,
     'GneMswnwEswGwsesMeswEnGeMseGwnwMnwnEwsGeMsGwneEneMsenenEwseMnwswseEe'),
    ('Lake4', 5,
     'GneMswnGwsMwGesEswMeswEneGenwEwsMnGeMsEnGeEseGswneMsenenwswseEe'),
    ('Sewer0', 0,
     'GnEwsesenGesesenEenwGswEeMsEwswnGenEeneMnGwEwsesGesMwseEwsenMnw'),
    ('Sewer0', 6,
     'GnEwsesesGeseseEneGnEwnwGsEsMswEnMeEsMwGnwMnwEwnesMsEwnMenw'),
    ('Sewer1', 0, 'MnEessGsEnwGsweEeswswewnGwwwEsensweMsenwse'),
    ('Sewer1', 11, 'MnEesGsEsGswwEwGewEesweGwMsenwse'),
    ('Sewer2', 0,
     'MnwGnEwneMeGnMwEneseswnMeseseGesesMwEwsGnwseEnGwEseGesEwseGnesenes'),
    ('Sewer2', 7,
     'GnEwMnwswEneMsEwnesesGsMenEwnMeseEsMwEnwseswGesEeGnesenes'),
    ('Sewer3', 0,
     'EsGwwseEnGwEsewGenEenneGsenEsenMsEwGsEeswMesEnMwEsGnMeGswMswwEsesww'
     'Mnsene'),
    ('Sewer3', 9,
     'GwwsenwEsesGenEnGsEnesMsGeEsGwEnMenEenwMsEesMwwEweswwMnsene'),
    ('SewerBonus', -18,
     'EwGwsesEeneGnewnEsGeEnewnwnGwEseneseeMnwneseGneseenesesEswGnwnwseEenese'
     'sweswMwnwswsEnwswswnwnGwswnwEseGnMnwneEwneMswsesGseswMnwneseenese'),
    ('SewerBonus', 0,
     'GwseEnwnGsEeGnewEwnGnwEseGeEsenewneseGwneseeMnEeneseGwenesesEswGneEenMw'
     'EwnwswsGwnwswsMsGwEnwnwnMwnwEsewGeMeswnEenGwMeseenese'),
    ('SewerBonus', 11,
     'EwGseEeneGneEnGwneEnewnwneseGwneseeMnEeneseMwGnwneseEsweGsneEnwnGwnEws'
     'GwMnEwnwsGwMwEnwnMnwEsesMeswnEnGwMeseenese'),
    ('Sewer5', 0,
     'EwnMeGswnenswnMswEswnewsGseEnGwEseGsEwseGnEwGseEenenMeneEswsMnEeMsw'
     'EwnenGnMn'),
    ('Sewer5', 5,
     'MseGswsEnwsGeMenGnseMsGwnEwnMwEewsesGseEnenenMeneEswMnEseMswEwnenGnMn'),
    ('City0', 0,
     'EwsGesenMenEnGeneMeneGsEeswMseGwEnwsGenwnesEwnwGnwEneGsEwGneEeswMs'),
    ('City0', 5,
     'GesEswGnMenwEenGsenMeGsEswMseGwEnwsGeneEnwGwneEnGwsEwGneEeswMs'),
    ('City1', 0, 'GwenwseMwseEwsGneEesenMsGwEwMenwGnesenwsMeGnMwGsenw'),
    ('City1', 9, 'EwsGnEenwsMsGeEsesenwGnesMeneGenMwGsenw'),
    ('City2', 0,
     'EeGneMnwsenesenwnEwnesenwMswswEnwswnewseseGwMnGeseMeEswGnwsEsGeEnwn'),
    ('City2', 2,
     'EeGneMnwsenesenwnEwMsEnesenwMnwseEnwswneseMnwGseEsGwEnesenwnwnMe'),
    ('CityBonus', 0,
     'GeswneMneGswnEeMnesGeMnwEnwGnMneseGeswMnwsesGnMwnGeswnMw'),
    ('CityBonus', 6, 'EnwGseMneswnesEeswMnEeGnEwMsEeGwMnwseGnMswnGeswnMw'),
    ('City4', 0,
     'GneseEswnwswsenesMsseEwnMneneGwEsenweGeMsenwEswsGwEnesGwnesEeMes'
     'Ewnwssw'),
    ('City4', 8,
     'GneseEswnwswsenMsseEesGwEwnMnesEeseMneEnwsMsEeGnMeGwEwGnesEwnwssw'),
    ('Space0', 0, 'GeswnesMwGnMesEsenGwsenwMwnEswnGeMen'),
    ('Space1', 0,
     'EsGnenwnEenwnenGeEsenMwGssMswnGnenEwnsenMswswnenwnGnwswMenwsesGeMnwGs'
     'Me'),
    ('Space1', 3,
     'EsGnenwnEenwnenGeEseMwswsGesEwsMwnenwnEeGnEwnsenGnwsMenwGwMsesGeMnwGs'
     'Me'),
    ('SpaceBonusA', 0,
     'MsEneseswGwseEeGsEwGneMnwGseEsGwseEneMsGwnesMenwEwMsen'),
    ('SpaceBonusA', 7, 'GwsEneseswGnenMwsGessEneGewnesMenwEwMsen'),
    ('Space3', 0,
     'GesenesMnwesEenesGeMsenEesGwMseGeneEneswneMwneEnwnwGswnwsEsGwEnenenwses'
     'MeEnMwsEwswnMnen'),
    ('Space3', 14,
     'MnweGesenesEenesMsEnMnEsMsEeGnMnwEeGeEwGeEnMneswGnMsenGsnMenwseswGwEwsw'
     'MnenEn'),
    ('SpaceBonusB', -14,
     'GeEwsenenwnenMeseEseswswsenMnsEsMensEwnMwsenwGnEseMeswnwseGswneEnwMenw'
     'GwEsenGeEseGwseEn'),
    ('SpaceBonusB', 0,
     'EwsenenwnenMeseEseswswseMnswseEeGnwnEwGswneEenwMenwGwEneGeEwseGwseEn'),
    ('SpaceBonusB', 7,
     'EwsenenwnenMeseEseswswMnsEseMnGnwMsGensMwnGwMsenEenGeEsGwEeGseEn'),
    ('Space5', 0,
     'MesGeEnwseswsneswMswsGwsEnMwsGeEnwGnwsMnGnwEnwswseGsesnwnMsEweMenGeEsw'
     'MsEeGsEwMwnwwnEnwsnwwssweMsEnwssenwsMnenEwMsEsenwMnwEssenwse'),
    ('Space5', 9,
     'MesGeEwneswsneswMswsGwMwsGseEnnGnwseEwsGnwnswwneEnwswseMseEnwssMwGs'
     'EenwseMnEwssweMsEwnnenwMnenEswMsEsenwMnwEsnenwse'),
]

ELEPHANT = 0
GOAT = 1
MOUSE = 2
NUM_ANIMALS = 3

#=============================================================================#

RE_PUZZ_LABEL = re.compile(r'^DataX_([a-zA-Z0-9_]+)_puzz:$', re.MULTILINE)
RE_TERRAIN_ROW = re.compile(
    r'^ *DB (.*)(?:\n.* (?:0|\$([0-9])([0-9])), (?:0|\$([0-9])([0-9])))?$',
    re.MULTILINE)
RE_ANIM = re.compile(r'D_ANIM \$([0-9a-f])([0-9a-f]),')
RE_PAR = re.compile(r'D_PAR \$([0-9]{4})')
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
        assert len(animals) == NUM_ANIMALS, (puzz_name, animals)
        puzzles[puzz_name] = {
            'animals': animals,
            'par': int(RE_PAR.search(asm, start, end).group(1)),
            'terrain': terrain_grid,
            'teleport': teleport,
        }
    return puzzles

#=============================================================================#

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

def is_blocked(position, direction, current_animal, animals, terrain, mods,
               allow_jump=True):
    if (position[0] < 0 or position[0] > 8 or
        position[1] < 0 or position[1] > 9):
        return True
    if position in animals: return True
    tile = mods.get(position) or terrain[position]
    if tile.startswith('W_'): return True
    if tile.startswith('M_') and current_animal != MOUSE: return True
    if tile.startswith('R_'):
        if current_animal != GOAT or not allow_jump: return True
        return is_blocked(apply_direction(position, direction), direction,
                          GOAT, animals, terrain, mods, allow_jump=False)
    if tile == 'S_BSH': return current_animal != GOAT
    if tile == 'S_PPW':
        return (current_animal != ELEPHANT or direction != 'e' or
                is_blocked((position[0], position[1] + 2), 'e', ELEPHANT,
                           animals, terrain, mods))
    if tile == 'S_PPE':
        return (current_animal != ELEPHANT or direction != 'w' or
                is_blocked((position[0], position[1] - 2), 'w', ELEPHANT,
                           animals, terrain, mods))
    return False

def make_move(direction, current_animal, animals, terrain, teleport, mods):
    moved = False
    while True:
        position = apply_direction(animals[current_animal], direction)
        if is_blocked(position, direction, current_animal, animals, terrain,
                      mods):
            if not moved:
                raise RuntimeError('pointless move {}'.format(direction))
            return
        moved = True
        animals[current_animal] = position
        tile = mods.get(position) or terrain[position]
        if tile == 'S_BSH':
            mods[position] = 'O_BST'
        elif tile == 'S_ARN': direction = 'n'
        elif tile == 'S_ARS': direction = 's'
        elif tile == 'S_ARE': direction = 'e'
        elif tile == 'S_ARW': direction = 'w'
        elif tile == 'S_PPW':
            if terrain[position] == 'S_PPW':
                mods[position] = 'O_EMP'
                mods[(position[0], position[1] + 2)] = 'S_PPE'
            else:
                del mods[position]
                del mods[(position[0], position[1] + 2)]
        elif tile == 'S_PPE':
            if terrain[position] == 'S_PPE':
                mods[position] = 'O_EMP'
                mods[(position[0], position[1] - 2)] = 'S_PPW'
            else:
                del mods[position]
                del mods[(position[0], position[1] - 2)]
        elif tile == 'S_MTP' and current_animal == MOUSE:
            raise RuntimeError('mouse hit mousetrap at {}'.format(position))
        elif (tile == 'S_TGE' and current_animal == GOAT or
              tile == 'S_TME' and current_animal == MOUSE):
            dest = teleport[(position[0], 'E')]
            if dest not in animals: animals[current_animal] = dest
        elif (tile == 'S_TEF' and current_animal == ELEPHANT or
              tile == 'S_TMF' and current_animal == MOUSE):
            dest = teleport[(position[0], 'F')]
            if dest not in animals: animals[current_animal] = dest

def test_solution(puzzle, solution, delta):
    animals = list(puzzle['animals'])
    terrain = {(row, col): tile for
               (row, tiles) in enumerate(puzzle['terrain']) for
               (col, tile) in enumerate(tiles)}
    teleport = puzzle['teleport']
    current_animal = ELEPHANT
    num_moves = 0
    mods = {}
    for char in solution:
        if char == ' ': pass
        elif char == 'E': current_animal = ELEPHANT
        elif char == 'G': current_animal = GOAT
        elif char == 'M': current_animal = MOUSE
        else:
            make_move(char, current_animal, animals, terrain, teleport, mods)
            num_moves += 1
    check_on_goal(animals[ELEPHANT], terrain, 'G_PNT')
    check_on_goal(animals[GOAT], terrain, 'G_APL')
    check_on_goal(animals[MOUSE], terrain, 'G_CHS')
    if num_moves + delta != puzzle['par']:
        raise RuntimeError('solved puzzle in {} moves ({} under), '
                           'but par is {}'
                           .format(num_moves, delta, puzzle['par']))

#=============================================================================#

MOVES = [(direction, animal)
         for animal in [MOUSE, GOAT, ELEPHANT]
         for direction in 'nsew']

def simplify(moves):
    simplified = ''
    animal = ''
    for char in moves:
        if char in 'EGM':
            if animal != char:
                simplified += char
                animal = char
        else:
            simplified += char
    return simplified

def is_solved(animals, terrain):
    (e_pos, g_pos, m_pos) = animals
    return ((e_pos[1] > 9 or terrain[e_pos] == 'G_PNT') and
            (g_pos[1] > 9 or terrain[g_pos] == 'G_APL') and
            (m_pos[1] > 9 or terrain[m_pos] == 'G_CHS'))

def solve_puzzle(puzzles, name):
    puzzle = puzzles[name]
    terrain = {(row, col): tile for
               (row, tiles) in enumerate(puzzle['terrain']) for
               (col, tile) in enumerate(tiles)}
    teleport = puzzle['teleport']
    initial_animals = tuple(puzzle['animals'])
    queue = collections.deque([('', initial_animals, {})])
    enqueued = set([(initial_animals, frozenset())])
    moves_length = 0
    while queue:
        (moves, old_animals, old_mods) = queue.popleft()
        if len(moves) > moves_length:
            moves_length = len(moves)
            print(moves_length // 2, ':', len(queue))
        for (direction, animal) in MOVES:
            animals = list(old_animals)
            mods = dict(old_mods)
            try:
                make_move(direction, animal, animals, terrain, teleport, mods)
            except RuntimeError:
                continue
            new_state = (tuple(animals), frozenset(mods))
            if new_state in enqueued:
                continue
            new_moves = moves + ('EGM'[animal] + direction)
            if is_solved(animals, terrain):
                return (len(new_moves) // 2, simplify(new_moves))
            queue.append((new_moves, animals, mods))
            enqueued.add(new_state)
    raise RuntimeError('no solution')

def solve_puzzles(puzzle_names):
    puzzles = load_puzzles()
    for puzzle_name in puzzle_names:
        (num_moves, moves) = solve_puzzle(puzzles, puzzle_name)
        print(puzzle_name)
        print(moves)
        print(num_moves)
        print()

#=============================================================================#

def run_tests():
    puzzles = load_puzzles()
    num_passed = 0
    num_failed = 0
    for (name, delta, solution) in SOLUTIONS:
        try:
            if name not in puzzles: raise RuntimeError('no such puzzle')
            test_solution(puzzles[name], solution, delta)
        except RuntimeError as err:
            print('FAILED: {}: {}'.format(name, err))
            num_failed += 1
        else: num_passed += 1
    print('solutions: {} passed, {} failed'.format(num_passed, num_failed))
    return (num_passed, num_failed)

if __name__ == '__main__':
    if len(sys.argv) > 1:
        solve_puzzles(sys.argv[1:])
    else:
        run_tests()

#=============================================================================#
