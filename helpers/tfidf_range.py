#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json

if len(sys.argv) < 3:
    print('Usage: python3 [].py contents')
    sys.exit()
else:
    tfidf = sys.argv[1]
    title = sys.argv[2]

tfidf = json.loads(tfidf.replace("'", '"').split("\n")[0])

title_arr = title.split(',')
lower_title = [x.lower() for x in title_arr]
for i in list(tfidf):
    if i.lower() in lower_title:
        del tfidf[i]
print(len(tfidf))
