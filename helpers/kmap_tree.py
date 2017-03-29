import json
import sys
import os
import re
import itertools
import ast
from collections import OrderedDict
import numpy as np

if len(sys.argv) < 4:
    print('Usage: python3 [].py cid chid name kmap_point')
    sys.exit()
else:
    cid = sys.argv[1]
    chid = sys.argv[2]
    name = sys.argv[3]
    kmap_point = sys.argv[4]

tfidf_keyword = list(ast.literal_eval(kmap_point))

# check if a sentence contains a certain word
def fit_sent(sentence, tfidf_keyword):
    keyword_arr = []
    word = re.sub(r'[：•/:/()。:，]+', '', sentence)
    word = re.sub(r'[().,…:@=?+]+', '', word)
    word = re.sub(r'(\d+)', '', word)
    word = word.strip()
    for keyword in tfidf_keyword:
        if len(keyword) > 0:
            if word.lower().find(keyword.lower()) >= 0:
                keyword_arr.append(keyword)
    return keyword_arr

#  find words of n-layer (n is 2,3,4,5)
def rows_keyword_valid(title, tfidf_keyword, json_txt, layer_num):
    row_keyword = {} # Rows to keyword
    for page in json_txt:
        check_title = json_txt[page]['1']['Content'].strip()
        if '：' in check_title:
            check_title = check_title.split('：')[1]
        if title == check_title: # check title
            for row, info in json_txt[page].items():
                if info['Layer'] == layer_num:
                    raw_sent = info['Content']
                    fit_sent_arr = fit_sent(raw_sent, tfidf_keyword)
                    if fit_sent_arr:
                        fit_sent_arr = list(set(fit_sent_arr))
                        if int(row) in row_keyword:
                            row_keyword[int(row)] = row_keyword[int(row)] + fit_sent_arr
                            row_keyword[int(row)] = list(set(row_keyword[int(row)]))
                        else:
                            row_keyword[int(row)] = fit_sent_arr
    return row_keyword

#  find words of more than n-layer (n is 5)
def rows_keyword_invalid(title, tfidf_keyword, json_txt, layer_num):
    row_keyword = {}
    for page in json_txt:
        check_title = json_txt[page]['1']['Content'].strip()
        if '：' in check_title:
            check_title = check_title.split('：')[1]
        if title == check_title: # check title
            for row, info in json_txt[page].items():
                if info['Layer'] >= layer_num:
                    raw_sent = info['Content']
                    fit_sent_arr = fit_sent(raw_sent, tfidf_keyword)
                    if int(row) in row_keyword:
                        row_keyword[int(row)] = row_keyword[int(row)] + fit_sent_arr
                        row_keyword[int(row)] = list(set(row_keyword[int(row)]))
                    else:
                        row_keyword[int(row)] = fit_sent_arr
    return row_keyword

# get the next and previous key:value of a particular key in a dictionary
def iterate(iterable):
    iterator = iter(iterable)
    item = next(iterator)
    for next_item in iterator:
        yield item, next_item
        item = next_item
    yield item, None

# title - layer_1
def build_level_one(title, level_one, tfidf_keyword):
    all_ = ()
    level_one = OrderedDict(sorted(level_one.items()))
    title_keyword = fit_sent(title, tfidf_keyword)
    level_one_keyword = []
    if level_one.values():
        for word in level_one.values():
            level_one_keyword += word
    Matrix = [[(y,x) for x in list(set(level_one_keyword)) if y != x] for y in title_keyword]
    if Matrix:
        for first in Matrix:
            for i in first:
                all_ = all_ + (i,)
    return all_

# layer_n - layer_n+1 (n is 1,2,3,4)
def build_level_n(pre, next_):
    all_ = ()
    if next_ != None:
        pre = OrderedDict(sorted(pre[1].items()))
        next_ = OrderedDict(sorted(next_[1].items()))
        for next_key in next_: # layer
            for next_item in next_[next_key]: # order
                tup = ()
                for pre_key in pre:
                    for pre_item in pre[pre_key]:
                        if next_key > pre_key:
                            if pre_item != next_item:
                                tup = ((pre_item, next_item),)
                if tup:
                    if tup[0] not in all_:
                        all_ = all_ + tup
    return all_

# Sort by first_layer and second_layer
def compare_level(first_, second_, compare_arr, final_dona, all_):
    for first_item in first_:
        compare_arr.append(first_item[1])
        compare_arr = list(set(compare_arr))
        if first_item not in final_dona and first_item not in all_:
            final_dona = final_dona + (first_item,)
    for second_item in second_:
        if first_ and second_:
            if second_item[0] in compare_arr and second_item[1] not in compare_arr:
                compare_arr.append(second_item[0])
                compare_arr.append(second_item[1])
                if first_item[1] == second_item[0] and second_item not in final_dona and second_item not in all_:
                    final_dona = final_dona + (second_item,)
        if second_ and not first_:
            if second_item[1] not in compare_arr:
                compare_arr.append(second_item[0])
                compare_arr.append(second_item[1])
                if second_item not in final_dona and second_item not in all_:
                    final_dona = final_dona + (second_item,)
    return final_dona

def paser_titles(title_path):
    titles = [line.rstrip('\n') for line in open(title_path)]
    return titles

def paser_content(content_path, titles):
    INVALID_VALUE = 6
    with open(content_path, 'r') as fr:
        json_txt = json.load(fr)
        done_ = ()
        for title in titles:
            compare_arr = []
            layer_dict = {} # key is layer number, value is keywords
            layer_arr = [] # push the layer numbers of the same title
            for page in json_txt:
                check_title = json_txt[page]['1']['Content'].strip()
                if '：' in check_title:
                    check_title = check_title.split('：')[1]
                if title == check_title: # check title
                    for row, info in json_txt[page].items():
                        if info['Layer'] not in layer_arr:
                            layer_arr.append(info['Layer'])
            layer_arr = sorted(layer_arr)
            if layer_arr:
                layer_arr.pop(0) # pull the layer number of title
            if layer_arr:
                layer_arr.pop(-1) # pull the layer number of page number
            if layer_arr:
                for layer in itertools.takewhile(lambda val: val != INVALID_VALUE, layer_arr): # suppose that the maximum of the layer number is 5
                    valid = rows_keyword_valid(title, tfidf_keyword, json_txt, layer)  # rows - keyword
                    layer_dict[layer] = valid # layers - rows - keyword
            if INVALID_VALUE in layer_arr:
                invalid = rows_keyword_invalid(title, tfidf_keyword, json_txt, INVALID_VALUE) # rows - keyword
                if invalid:
                    layer_dict[INVALID_VALUE] = invalid # layers - rows - keyword
            # zero_ = build_layer_zero(title, tfidf_keyword)
            if layer_dict:
                first_ = build_level_one(title, layer_dict[2], tfidf_keyword)
                second_ = ()
                for item, next_item in iterate(layer_dict.items()):
                    tup = build_level_n(item, next_item)
                    second_ = second_ + tup
                first_done = ()
                firandsec_done = ()
                second_done = ()
                if first_ and not second_:
                    first_done = compare_level(first_, second_, compare_arr, first_done, done_)
                    done_ = done_ + first_done
                if first_ and second_:
                    firandsec_done = compare_level(first_, second_, compare_arr, firandsec_done, done_)
                    done_ = done_ + firandsec_done
                if second_ and not first_:
                    second_done = compare_level(first_, second_, compare_arr, second_done, done_)
                update_second = ()
                for second_item in second_done:
                    if second_item not in done_:
                        for done_item in done_:
                            if second_item[0] == done_item[1] and second_item[1] != done_item[0]:
                                if second_item not in update_second:
                                    update_second = update_second + (second_item,)
                done_ = done_ + update_second
        #     done_ = zero_ + done_
        return done_

def tup_dict_to_tree(name, links):
    name_to_node = {}
    root = {'name': name, 'children': []}
    for parent, child in links:
        parent_node = name_to_node.get(parent)
        if not parent_node:
            name_to_node[parent] = parent_node = {'name': parent}
            root['children'].append(parent_node)
        name_to_node[child] = child_node = {'name': child}
        parent_node.setdefault('children', []).append(child_node)
    for j in root['children']:
        if j['name'] == '':
            for k in j['children']:
                if k not in root['children']:
                    root['children'].append(k)
    for j in root['children']:
        if j['name'] == '':
            root['children'].remove(j)
    return root

title_path = '../k-map/title/' + cid + '/' + chid + '.txt'
content_path = '../k-map/slide_layer/' + cid + '/' + chid + '.json'
titles = paser_titles(title_path)
tup_dict = paser_content(content_path, titles)
final_json = tup_dict_to_tree(name, tup_dict)
print(final_json)
