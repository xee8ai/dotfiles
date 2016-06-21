#!/usr/bin/env python3

import os
import os.path
from pprint import pprint
import sys

home_dir = os.getenv('HOME')
base_path = os.path.join(home_dir, '.gitignore_templates', 'gitignore')

if not os.path.isdir(base_path):
    print('There is no template dir ({}). Exiting…'.format(base_path))
    sys.exit(1)

ignore_files = {
        'python': 'Python.gitignore',
        'tags': os.path.join('Global', 'Tags.gitignore'),
        'tex': 'TeX.gitignore',
        'vim': os.path.join('Global', 'Vim.gitignore'),
        }
default_added = ['tags', 'vim']

header_tpl = '''
################################################################################
# {}
################################################################################
'''

option_list = [o for o in ignore_files.keys() if o not in default_added]

def usage():
    print('Usage: {} [{}]* target_dir'.format(sys.argv[0], '|'.join(option_list)))
    print('Exiting…')
    sys.exit(1)

# check if at least 3 args are given
if len(sys.argv) < 3 :
    usage()

# check if last argument is existing directory
target_dir = sys.argv.pop()
if not os.path.isdir(target_dir):
    print('{} is not a directory'.format(target_dir))
    usage()

ignores = sys.argv[1:] + default_added

# check if given arguments are valid
allowed = list(ignore_files.keys())
for i in ignores:
    if i not in allowed:
        print('{} is not valid'.format(i))
        usage()

file_parts = []
for i in ignores:
    header = header_tpl.format(i)
    source = os.path.join(base_path, ignore_files[i])
    with open(source, 'r') as fh:
        content = fh.read()
    part = header + '\n' + content
    file_parts.append(part)


file_content = '\n\n'.join(file_parts)

gitignore_file = os.path.join(target_dir, '.gitignore')
with open(gitignore_file, 'w') as fh:
    fh.write(file_content)
print('Whooo!!')
