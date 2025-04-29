#!/usr/bin/env python3

import subprocess
import sys

out_bytes = subprocess.check_output(["git", "config", "-l"])
out_text = out_bytes.decode("utf-8")
out_lines = out_text.split("\n")

name = "n/a"
email = "n/a"

for line in out_lines:
    if "user.name" in line:
        name = line.split("=")[1].strip()
    if "user.email" in line:
        email = line.split("=")[1].strip()

info = "{} ({})".format(name, email)

# colorize under linux (assume we are using bash)
if sys.platform.startswith("linux"):
    if name == "n/a" or email == "n/a":
        info = "\033[1;31m" + info + "\033[0m"
    else:
        info = "\033[0;34m" + info + "\033[0m"

# add explanatory text
info = "Your git identity is: " + info


print()
print(info)
print()
