#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import json

if len(sys.argv) < 2:
    print('Usage: python3 [].py contents')
    sys.exit()
else:
    slide = sys.argv[1]
    subtitle = sys.argv[2]

slide = json.loads(slide.replace("'", '"'))
subtitle = json.loads(subtitle.replace("'", '"'))
intersection = set(slide.keys()).intersection(set(subtitle.keys()))  # 相同的
for word in intersection:
    ratio = (subtitle[word]['order']*0.7) + (slide[word]/100*0.3)
    subtitle[word]['order'] = ratio

difference = set(slide.keys()).difference(set(subtitle.keys()))
union = set(slide.keys()).union(set(subtitle.keys()))
for word in difference:
    word_list = {}
    word_list['order'] = slide[word]/100
    subtitle[word] = word_list
print(subtitle)
