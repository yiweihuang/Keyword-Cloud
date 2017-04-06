import json
import sys
import os
import re
import itertools
import ast
from collections import OrderedDict
from nltk.stem import WordNetLemmatizer
import numpy as np

if len(sys.argv) < 4:
    print('Usage: python3 [].py cid chid name kmap_point')
    sys.exit()
else:
    cid = sys.argv[1]
    chid = sys.argv[2]
    name = sys.argv[3]
    kmap_point = sys.argv[4]

tfidf_keyword_raw = list(ast.literal_eval(kmap_point))
lemmatizer = WordNetLemmatizer()
tfidf_keyword = {}
for i in tfidf_keyword_raw:
    word = re.sub(r'[：•/:/()。:，]+', '', i)
    word = re.sub(r'[().,…:@=?+]+', '', word)
    word = re.sub(r'(\d+)', '', word)
    word = word.strip()
    tfidf_keyword[word] = i

# check if a sentence contains a certain word
def fit_sent(sentence, tfidf_keyword):
    keyword_arr = []
    word = re.sub(r'[：•/:/()。:，]+', '', sentence)
    word = re.sub(r'[().,…:@=?+]+', '', word)
    word = re.sub(r'(\d+)', '', word)
    word = word.strip()
    for keyword in list(tfidf_keyword.keys()):
        if len(keyword) > 0:
            if word.lower().find(keyword.lower()) >= 0:
                keyword_arr.append(tfidf_keyword[keyword])
    return keyword_arr

#  find words of n-layer (n is 2,3,4,5)
def rows_keyword_valid(page, tfidf_keyword, json_txt, layer_num):
    row_keyword = {} # Rows to keyword
    # for page in range(start + 1, end):
    for row, info in json_txt[str(page)].items():
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
def rows_keyword_invalid(page, tfidf_keyword, json_txt, layer_num):
    row_keyword = {}
    # for page in range(start + 1, end):
    for row, info in json_txt[str(page)].items():
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
def build_level_one(title, level_one):
    all_ = ()
    level_one = OrderedDict(sorted(level_one.items()))
    title_keyword = [title]
    level_one_keyword = []
    if level_one.values():
        for word in level_one.values():
            level_one_keyword += word
    Matrix = [[(y,x) for x in list(set(level_one_keyword)) if lemmatizer.lemmatize(y.lower()) != x.lower()] for y in title_keyword]
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

def get_key(key):
    try:
        return int(key)
    except ValueError:
        return key

def slice_page(path):
    same_page_arr = []
    outline_arr = []
    with open(path, 'r') as fr:
        str_content = []
        json_txt = json.load(fr)
        end_page = len(json_txt) + 1
        json_txt = OrderedDict(sorted(json_txt.items(), key=lambda t: get_key(t[0])))
        for page in json_txt:
            json_txt[page].pop(str(len(json_txt[page])))
            str_content.append(str(json_txt[page]))
        dups = [x for x in str_content if str_content.count(x) > 1]
        for line in list(set(dups)):
            temp_ = []
            for outline in range(2, len(ast.literal_eval(line)) +1):
                word = ast.literal_eval(line)[str(outline)]['Content']
                word = word.strip()
                temp_.append(word)
            outline_arr.append(temp_)
            same_page_arr.append([i+1 for i, x in enumerate(str_content) if x == line])
    index = list(len(l) for l in same_page_arr).index(max(list(len(l) for l in same_page_arr)))
    same_page_arr[index].append(end_page)
    return {'page':same_page_arr[0],'outline':outline_arr[0]} if len(same_page_arr) == 1 else {'page':same_page_arr[index],'outline':outline_arr[index]}

def paser_titles(title_path):
    titles = [line.rstrip('\n') for line in open(title_path)]
    return titles

def paser_content(content_path, titles, tfidf_keyword):
    INVALID_VALUE = 6
    COUNT = 0
    outline = slice_page(content_path)
    with open(content_path, 'r') as fr:
        json_txt = json.load(fr)
        slice_ = ()
        for item, next_item in iterate(outline['page']):
            if next_item != None:
                if (next_item - item) == 1:
                    outline['page'].remove(item)
        for item, next_item in iterate(outline['page']):
            if next_item != None:
                temp_dict = []
                zero_ = (('', outline['outline'][COUNT]),)
                for page in range(item + 1, next_item):
                    layer_dict = {}
                    layer_arr = []
                    for row, info in json_txt[str(page)].items():
                        if info['Layer'] not in layer_arr:
                            layer_arr.append(info['Layer'])
                    layer_arr = sorted(layer_arr)
                    if layer_arr:
                        layer_arr.pop(-1) # pull the layer number of page number
                    if layer_arr:
                        for layer in itertools.takewhile(lambda val: val != INVALID_VALUE, layer_arr): # suppose that the maximum of the layer number is 5
                            valid = rows_keyword_valid(page, tfidf_keyword, json_txt, layer)  # rows - keyword
                            layer_dict[layer] = valid # layers - rows - keyword
                    if INVALID_VALUE in layer_arr:
                        invalid = rows_keyword_invalid(page, tfidf_keyword, json_txt, INVALID_VALUE) # rows - keyword
                        if invalid:
                            layer_dict[INVALID_VALUE] = invalid # layers - rows - keyword
                    temp_dict.append(layer_dict)
                compare_arr = []
                done_ = ()
                for layer_row in temp_dict:
                    first_ =()
                    second_ = ()
                    if layer_row and layer_row[1]:
                        if outline['outline'][COUNT] not in layer_row[1][1]:
                            first_ = build_level_one(outline['outline'][COUNT], layer_row[1])
                            second_ = ()
                            for item, next_item in iterate(layer_row.items()):
                                tup = build_level_n(item, next_item)
                                second_ = second_ + tup
                        else:
                            del layer_row[1]
                            if layer_row and layer_row[2]:
                                first_ = build_level_one(outline['outline'][COUNT], layer_row[2])
                                second_ = ()
                                for item, next_item in iterate(layer_row.items()):
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
                done_ = zero_ + done_
            slice_ = slice_ + done_
            COUNT += 1
        return slice_

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
tup_dict = paser_content(content_path, titles, tfidf_keyword)
final_json = tup_dict_to_tree(name, tup_dict)
print(final_json)
