#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import re

if len(sys.argv) < 2:
    print('Usage: python3 [].py contents')
    sys.exit()
else:
    cid = sys.argv[1]
    chid = sys.argv[2]

path = '../k-map/result/' + cid + '/' + chid + '.txt'
result = {}
with open(path, "r") as text:
    for line in text:
        word, tfidf = line.strip().split('\t')
        result[word] = float(tfidf)
print(result)
