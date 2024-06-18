#!/usr/bin/env python3

from pprint import pprint
import random
import sys

def get_hex():
    h = hex(random.randint(0, 255))
    s = f'{h}'
    s = s.replace('0x', '')
    if len(s) == 1:
        s = f'0{s}'
    return s

def get_mac():
    l = []
    for i in range(6):
        l.append(get_hex())
    return ':'.join(l)

def help():
    print()
    print('Creates one or more random MAC addresses')
    print()
    print(f'Usage: {sys.argv[0]} [count]')
    print('    if count is given create that number of MAC addresses (or one if not present)')
    print()

if __name__ == '__main__':
    count = 1
    if len(sys.argv) == 2:
        try:
            count = int(sys.argv[1])
        except Exception as ex:
            help()
            sys.exit(1)

    if count < 1:
        print('Error: Argument needs to be at least 1')
        sys.exit(1)

    print()
    for i in range(count):
        print(f'{get_mac()}')
    print()
