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

import os
import re

#=============================================================================#

# A target for an ldh instruction can be "c", or "rFOO" (if "FOO" doesn't start
# with "RAM" or "ROM", since those hardware registers are actually in the
# cartridge ROM address space, not the $ff page), or an "Hram_Foo" label.
LDH_TARGET = r'(?:c|r(?!R[AO]M)[A-Z0-9]+|Hram_[a-zA-Z0-9_]+)'
LD_WITH_LDH_TARGET = r'ld a, \[{0}\]|ld \[{0}\], a'.format(LDH_TARGET)

PATTERNS = [
    ('exported private label', re.compile(r'^_[a-zA-Z0-9_]+::')),
    ('ld instead of ldh', re.compile(LD_WITH_LDH_TARGET)),
    ('over-long line', re.compile(r'^.{80,}\n$')),
    ('tab character', re.compile(r'\t')),
    ('TILE_ID instead of TILEID', re.compile(r'TILE_ID')),
]

#=============================================================================#

def run_tests():
    num_passed = 0
    num_failed = 0
    for (message, pattern) in PATTERNS:
        num_matches = 0
        for (dirpath, dirnames, filenames) in os.walk('src'):
            for filename in filenames:
                if not (filename.endswith('.asm') or
                        filename.endswith('.inc')):
                    continue
                if filename == 'hardware.inc': continue
                filepath = os.path.join(dirpath, filename)
                for (line_number, line) in enumerate(open(filepath)):
                    if pattern.search(line):
                        if num_matches == 0:
                            print('LINT: found ' + message)
                        num_matches += 1
                        print('  {}:{}:'.format(filepath, line_number + 1))
                        print('    ' + line.strip())
        if num_matches == 0: num_passed += 1
        else: num_failed += 1
    print('lint: {} passed, {} failed'.format(num_passed, num_failed))
    return (num_passed, num_failed)

if __name__ == '__main__':
    run_tests()

#=============================================================================#
