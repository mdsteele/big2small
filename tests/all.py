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

import lint
import solutions
import spelling

#=============================================================================#

def run_tests():
    results = [0, 0]
    def run(module):
        (num_passed, num_failed) = module.run_tests()
        results[0] += num_passed
        results[1] += num_failed
    run(lint)
    run(solutions)
    run(spelling)
    print('all: {} passed, {} failed'.format(*results))
    return tuple(results)

if __name__ == '__main__':
    run_tests()

#=============================================================================#
