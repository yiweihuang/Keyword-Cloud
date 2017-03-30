#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import re

if len(sys.argv) < 2:
    print('Usage: python3 [].py contents')
    sys.exit()
else:
    info = sys.argv[1]

type_convert = {}
info = re.split("{", info)[1]
info = re.split("}", info)[0]
info = info.split(", ")
for x in info:
    type_convert[x.split("=>")[0]] = x.split("=>")[1]

word_tfidf = {}
delete_list = []
for item in type_convert:
    if type_convert.get(item) != '':
        word_tfidf.update({item:
                           float(type_convert.get(item)) +
                           (float(type_convert.get(item))*(len(item.split("+"))-1)*0.5)
                           })
# 文字串接
pattern_ch = r'[\u4e00-\u9fa5]+'
pattern_en = r'[A-Za-z]+'
pattern_mark = r'[/]+'
pattern_num = r'[0-9]+\.[0-9]+'
key_list = list(word_tfidf.keys())
for i in range(len(word_tfidf)):
    key_line = key_list[i].split("+")
    new_key = ""
    last_word = ""
    for word in key_line:
        if(re.match(pattern_ch, last_word)):
            if(re.match(pattern_en, word) or
               re.match(pattern_num, word)):
                new_key += (" " + word)
            else:
                new_key += word
        elif(re.match(pattern_en, last_word) or
             re.match(pattern_num, last_word)):
            if(re.match(pattern_mark, word)):
                new_key += word
            else:
                new_key += (" " + word)
        elif(re.match(pattern_mark, last_word)):  # /
            new_key += word
        else:  # first word
            new_key += word
        last_word = word

    word_tfidf[new_key] = word_tfidf.pop(key_list[i])

for item1 in word_tfidf:
    for item2 in word_tfidf:
        if(item1 in item2):
            if(word_tfidf.get(item1) < word_tfidf.get(item2)):
                if(item1 not in delete_list):
                    delete_list.append(item1)
            elif(word_tfidf.get(item1) > word_tfidf.get(item2)):
                if(item2 not in delete_list):
                    delete_list.append(item2)
            else:  # judge if self or not
                if(len(item1) > len(item2) and item2 not in delete_list):
                    delete_list.append(item2)
                elif(len(item1) < len(item2) and item1 not in delete_list):
                    delete_list.append(item1)
                else:
                    continue

# remove items
for item in delete_list:
    word_tfidf.pop(item)

# string to float
for item in word_tfidf:
    word_tfidf.update({item: float(word_tfidf.get(item))})


rev_multidict = {}
for key, value in word_tfidf.items():
    rev_multidict.setdefault(value, set()).add(key)
multi_list = [key for key, values in rev_multidict.items() if len(values) > 1]
ave = round(sum(multi_list) / float(len(multi_list)))

for item in list(word_tfidf):
    if float(word_tfidf.get(item)) < ave:
        word_tfidf.pop(item)

for item in list(word_tfidf):
    if float(word_tfidf.get(item)) > 1000.0:
        word_tfidf.update({item: float(word_tfidf.get(item))/50})

print(word_tfidf)
# print("%s" % (word_tfidf.encode('utf-8')))
