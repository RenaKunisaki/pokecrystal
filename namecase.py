#!/usr/bin/env python3
"""Change names to proper case."""

import re

with open("data/trainers/parties.asm", 'rt') as file:
    with open("data/trainers/parties.out", 'wt') as outFile:
        for line in file:
            m = re.search(r'db "(.+)"', line)
            if m:
                s, e = m.span(1)
                outFile.write(line[0:s] + line[s:e].title() + line[e:])
            else: outFile.write(line)
