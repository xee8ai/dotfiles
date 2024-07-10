#!/usr/bin/env python3

import sys

print()

try:
    s = int(sys.argv[1])
except (ValueError, IndexError):
    print("Excpecting integer as argument")
    print()
    sys.exit(1)
except Exception as ex:
    raise ex

m, s = divmod(s, 60)
print("Minutes:")
print(f"{m} minutes and {s} seconds")
print(f"{m:02}:{s:02}")
print()

h, m = divmod(m, 60)
print("Hours:")
print(f"{h} hours, {m} minutes and {s} seconds")
print(f"{h:02}:{m:02}:{s:02}")
print()

d, h = divmod(h, 24)
print("Days:")
print(f"{d} days, {h} hours, {m} minutes and {s} seconds")
print(f"{d} {h:02}:{m:02}:{s:02}")
print()

print()
