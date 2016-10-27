#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import json
import math

if len(sys.argv) < 2:
    print('Usage: python3 [].py contents')
    sys.exit()
else:
    slide = sys.argv[1]
    concept = sys.argv[2]

slide = json.loads(slide.replace("'", '"'))
wordlist = concept.split('\n')[0]
wordlist = wordlist.split(',')
length =len(slide)
value = math.ceil(sum(slide.values())/length)
intersection = set(wordlist).intersection(set(slide.keys()))
for word in intersection:
    ratio = slide[word] + value
    slide[word] = ratio

difference = set(wordlist).difference(set(slide.keys()))
for word in difference:
    slide[word] = value

print(slide)
