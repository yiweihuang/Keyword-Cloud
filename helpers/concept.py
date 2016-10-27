#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import json
import math

if len(sys.argv) < 1:
    print('Usage: python3 [].py contents')
    sys.exit()
else:
    concept = sys.argv[1]

wordlist = concept.split('\n')[0]
wordlist = wordlist.split(',')
length = len(wordlist)
value = math.ceil(100 / length)
concept_dict = {}

for word in wordlist:
    concept_dict[word] = value

print(concept_dict)
