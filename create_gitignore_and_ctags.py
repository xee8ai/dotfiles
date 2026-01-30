#!/usr/bin/env python3

import os
import os.path
from pprint import pprint
import sys

if sys.platform.startswith("linux"):
    home_dir = os.getenv("HOME")
    base_path = os.path.join(home_dir, ".gitignore_templates")
elif sys.platform.startswith("win"):
    base_path = "w:\_gitignore_templates"
else:
    print(
        "Operating system {} is not supported. Exiting...".format(
            sys.platform.startswith
        )
    )
    sys.exit(1)

if not os.path.isdir(base_path):
    print("There is no template dir ({}). Exiting...".format(base_path))
    sys.exit(1)

ignore_files = {
    "c": os.path.join("gitignore", "C.gitignore"),
    "java": os.path.join("gitignore", "Java.gitignore"),
    "php": None,
    "laravel": os.path.join("gitignore", "Laravel.gitignore"),
    "python": os.path.join("gitignore", "Python.gitignore"),
    "tags": os.path.join("gitignore", "Global", "Tags.gitignore"),
    "tex": os.path.join("gitignore", "TeX.gitignore"),
    "vim": os.path.join("gitignore", "Global", "Vim.gitignore"),
}
default_added = ["tags", "vim"]

ctags_content = {
    "c": [],
    "java": [],
    "laravel": [
        "--exclude=vendor/*",
    ],
    "php": [
        "--exclude=vendor/*",
    ],
    "python": [
        "--exclude=venv/*",
    ],
    "tags": [
        "--recurse=yes",
        "--exclude=.git/*",
    ],
    "tex": [],
    "vim": [],
}

header_tpl = """
################################################################################
# {}
################################################################################
"""

option_list = [o for o in sorted(ignore_files.keys()) if o not in default_added]


def usage():
    print()
    print("Usage: {} types* target_dir".format(sys.argv[0]))
    print()
    print("    Types can be multiple values from [{}]".format("|".join(option_list)))
    print("    If no types are given then .gitignore will")
    print('        be created for "{}" only.'.format('" and "'.join(default_added)))
    print("        These will be added to each generated .gitignore file")
    print()
    print("Exiting...")
    print()
    sys.exit(1)


# check if at least 2 args are given
if len(sys.argv) < 2:
    usage()

# check if last argument is existing directory
target_dir = sys.argv.pop()
if not os.path.isdir(target_dir):
    print("{} is not a directory".format(target_dir))
    usage()

ignores = sys.argv[1:] + default_added

# check if given arguments are valid
allowed = list(ignore_files.keys())
for i in ignores:
    if i not in allowed:
        print("{} is not valid".format(i))
        usage()


file_parts = []
for i in ignores:
    header = header_tpl.format(i)
    if not ignore_files[i]:
        continue
    source = os.path.join(base_path, ignore_files[i])
    with open(source, "r") as fh:
        content = fh.read()
    part = header + "\n" + content
    file_parts.append(part)

file_parts.append(header_tpl.format("Manually added entries"))

file_content = "\n\n".join(file_parts)

gitignore_file = os.path.join(target_dir, ".gitignore")
with open(gitignore_file, "w") as fh:
    fh.write(file_content)
print("Wrote {}".format(gitignore_file))

# create .ctags to keep tags file small :-)
data = ctags_content["tags"]
for i in ignores:
    if i != "tags":
        for c in ctags_content[i]:
            data.append(c)

ctags_files = [
    os.path.join(target_dir, ".ctags"),
    os.path.join(target_dir, ".gutctags"),
]
file_content = "\n".join(data)

for ctags_file in ctags_files:
    with open(ctags_file, "w") as fh:
        fh.write(file_content)
    print(f"Wrote {ctags_file}")

print()
print("Whooo!!")
