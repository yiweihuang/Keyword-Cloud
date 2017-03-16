#!/usr/bin/env python
# -*- coding: utf-8 -*-
import jieba
import sys
import re
from nltk.stem import WordNetLemmatizer
import operator

if len(sys.argv) < 2:
    print('Usage: python3 [].py contents')
    sys.exit()
else:
    slides = sys.argv[1]

# jieba.set_dictionary('lib/dict/dict.txt.big')
# jieba.load_userdict('lib/dict/dict.txt.big')
stop = open("lib/dict/stopwords.txt").read()
lemmatizer = WordNetLemmatizer()
max_ngram = 4
ngram_counts = {}
pattern = r'[A-Za-z/]+|[0-9]+\.[0-9]+|[\u4e00-\u9fa5]'
seg_list = jieba.cut(slides, cut_all=False)
words_line = list(seg_list)
words_line_clean = []
for word in words_line:
    if(re.match(pattern, word) is not None and word not in stop):
        words_line_clean.append(word)

# 英文單字預處理
for i in range(len(words_line_clean)):
    if(re.match(r"[A-Za-z]+", words_line_clean[i]) is not None):
        # 還原開頭大寫，縮寫不還原
        if(len(words_line_clean[i]) > 1 and words_line_clean[i][0].isupper() and words_line_clean[i][1].islower()):
            words_line_clean[i] = words_line_clean[i].lower()
        # 還原N為單數
        words_line_clean[i] = lemmatizer.lemmatize(words_line_clean[i])

# Ngram Processing
for i in range(len(words_line_clean)):
    for n in range(1, max_ngram+1):
        if(i+n <= len(words_line_clean)):
            ngram = r"+".join(words_line_clean[i:i+n])
            # word_count
            count = ngram_counts.get(ngram)
            if count is None:
                ngram_counts.update({ngram: 1})
            else:
                ngram_counts.update({ngram: count+1})

for key, value in sorted(ngram_counts.items(),
                         key=operator.itemgetter(1),
                         reverse=True):
    print("%s\t%s\n" % (key, value))

# for key, value in sorted(ngram_counts.iteritems(), key=lambda (k, v): (v, k), reverse=True):
#     print("%s\t%s\n" % (key.encode('utf-8'), value))
