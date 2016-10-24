#!/usr/bin/env python
# -*- coding: utf-8 -*-
import jieba
import jieba.analyse
import datetime
import sys
import json

if len(sys.argv) < 2:
    print('Usage: python3 [].py contents')
    sys.exit()
else:
    subtitle = sys.argv[1]
    slide = sys.argv[2]

jieba.set_dictionary('lib/dict/dict.txt.big')
slide = json.loads(slide.replace("'", '"').split("\n")[0])
concept = slide.keys()
for word in concept:
    jieba.add_word(word, freq=None, tag=None)

content_list = subtitle.split('\n')
for index, content in enumerate(content_list):
    if index % 4 == 1:
        # time
        time = content.split()
        time.pop(1)
        start = datetime.datetime.strptime(time[0], "%H:%M:%S,%f")
        end = datetime.datetime.strptime(time[1], "%H:%M:%S,%f")
        video_start = start.minute*60 + start.second
        video_end = end.minute*60 + end.second
        # keywords
        words = jieba.analyse.extract_tags(content_list[index + 1],
                                           topK=5,
                                           withWeight=False,
                                           allowPOS=())
        tmp_word = []
        for word in words:
            tmp_word.append(word)
