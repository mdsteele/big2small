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

RE_DLOG_LABEL = re.compile(r'^DataX_([a-zA-Z0-9_]+)_dlog:', re.MULTILINE)
RE_DLOG_LINE = re.compile(r'^ +DB +(DIALOG_[A-Z0-9_]+|"(?:[^"\\]|\\[a-z])*")',
                          re.MULTILINE)
RE_DOUBLE_NEWLINE = re.compile(r'\n\n')

def load_dialogues():
    dlogs = []
    asm = open('src/dlogdata.asm').read()
    for label_match in RE_DLOG_LABEL.finditer(asm):
        dlog_name = label_match.group(1)
        start = label_match.end()
        end = RE_DOUBLE_NEWLINE.search(asm, start).start()
        dlog_lines = [match.group(1) for match in
                      RE_DLOG_LINE.finditer(asm, start, end)]
        dlogs.append({
            'name': dlog_name,
            'lines': dlog_lines,
        })
    return dlogs

#=============================================================================#

def malformed_error(dlog_lines):
    state = 'BEGIN'
    lineno = 0
    for line in dlog_lines:
        if state == 'BEGIN':
            if line == 'DIALOG_END':
                state = 'END'
            elif line.startswith('DIALOG_'):
                state = 'TEXT'
                lineno = 0
            else: return '{} after completed text'.format(line)
        elif state == 'TEXT':
            if line.startswith('DIALOG_'):
                return '{} after incomplete text'.format(line)
            if line.endswith('\\n"'):
                lineno += 1
                if lineno >= 3:
                    return '{} as third line of text'.format(line)
            elif line.endswith('\\r"'):
                state = 'BEGIN'
            else:
                return '{} without terminator'.format(line)
            length = len(line) - 4  # subtract quotes and termination escape
            if length > 15:
                return '{} with {} chars'.format(line, length)
            if '.  ' in line or '!  ' in line or '?  ' in line:
                return '{} with double space'.format(line)
        elif state == 'EMD':
            return '{} after DIALOG_END'.format(line)
        else: assert False
    return None

#=============================================================================#

WORDS = set(line.strip() for line in open('tests/wordlist.txt'))
RE_WORD = re.compile(r"[a-zA-Z0-9'-]+")

def spelling_errors(dlog_lines):
    errors = []
    for line in dlog_lines:
        if line.startswith('DIALOG_'):
            continue
        line = line.replace('\\n', ' ').replace('\\r', ' ')
        words = RE_WORD.findall(line)
        for word in words:
            if word.startswith("'") and word.endswith("'"):
                word = word[1:-1]
            if word not in WORDS and word.lower() not in WORDS:
                errors.append(word)
    return errors

#=============================================================================#

def run_tests():
    num_passed = 0
    num_failed = 0
    for dlog in load_dialogues():
        error = malformed_error(dlog['lines'])
        if error is not None:
            print('{}: Found {}'.format(dlog['name'], error))
            num_failed += 1
            continue
        errors = spelling_errors(dlog['lines'])
        if errors:
            for error in errors:
                print('{}: Found "{}" misspelled'.format(dlog['name'], error))
            num_failed += 1
            continue
        num_passed += 1
    print('spelling: {} passed, {} failed'.format(num_passed, num_failed))
    return (num_passed, num_failed)

if __name__ == '__main__':
    run_tests()

#=============================================================================#
