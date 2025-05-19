#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import errno
import argparse
import shutil


parser = argparse.ArgumentParser()
parser.add_argument('-o', '--omit', nargs='+', help='Dirs and/or files to omit')
parser.add_argument('-i', '--include', nargs='+', help='Dirs and/or files to move')
parser.add_argument('-a', '--all', action='store_true', help='Move all dirs and files')
parser.add_argument('-c', '--confirm', action='store_true', help='Ask confirmation for each dir and file')

args = parser.parse_args()

df_to_omit = []
df_to_include = []

len_args = len(sys.argv)
aargs = sys.argv
cwd = os.getcwd()

if cwd in ('/home/stephane/.local/bin', '/home/stephane/bin'):
    print(f'ldmv impossible here... -> {cwd}')
    sys.exit()

dest = './BAK/'

def ld_mv(elem):
    shutil.move(elem, f'{dest}{elem}')
    print(f'Moving {elem} to {dest}{elem}')

def ld_and_move(v):
    if v == 0:
        for f in os.listdir():
            if f not in df_to_omit and f != 'BAK':
                ld_mv(f)
    elif v == 1:
        for f in os.listdir():
            if f in df_to_include and f != 'BAK':
                ld_mv(f)
    elif v == 2:
        for f in os.listdir():
            if f != 'BAK':
                ld_mv(f)

def ld_and_moveI():
    for f in os.listdir():
        c = input(f'Move {f}? [y|n]: ')
        if c == 'y':
            ld_mv(f)

tst = True
if os.path.isdir('./BAK') is False:
    c_bak = input('BAK dir doesn\'t exist. Create it? [y|n]: ')
    if c_bak == 'y':
        try:
            os.makedirs('BAK')
        except OSError as e:
            tst = False
            if e.errno != errno.EEXIST:
                raise
    else:
        tst = False

e = 0
if tst:
    if args.omit:
        for e in range(2, len_args):
            df_to_omit.append(aargs[e])
        ld_and_move(0)
    elif args.include:
        for e in range(2, len_args):
            df_to_include.append(aargs[e])
        ld_and_move(1)
    elif args.all or len_args == 1:
        ld_and_move(2)
    elif args.confirm:
        ld_and_moveI()
    else:
        sys.exit()

