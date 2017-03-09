#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json

if len(sys.argv) < 3:
    print('Usage: python3 [].py contents')
    sys.exit()
else:
    tfidf = sys.argv[1]
    number = sys.argv[2]
    title = sys.argv[3]

tfidf = json.loads(tfidf.replace("'", '"').split("\n")[0])
number = int(number)

title_arr = title.split(',')
lower_title = [x.lower() for x in title_arr]
for i in list(tfidf):
    if i.lower() in lower_title:
        del tfidf[i]
tfidf_item = tfidf.items()

for i in range(0, number, 1):
    print(list(tfidf_item)[i])
