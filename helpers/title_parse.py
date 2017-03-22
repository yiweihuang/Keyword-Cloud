import json
import sys
import os

if len(sys.argv) < 3:
    print('Usage: python3 [].py type week1')
    sys.exit()
else:
    cid = sys.argv[1]
    chid = sys.argv[2]


def paser_step_one(path, write_title):
    title = []
    try:
        with open(path, 'r') as fr:
            json_txt = json.load(fr)
            for page in json_txt:
                if page != '1':
                    title_name = json_txt[page]['1']['Content']
                    title_name = title_name.strip()
                    if title_name not in title:
                        title.append(title_name)
        os.remove(write_title) if os.path.exists(write_title) else None
        fw = open(write_title, 'w')
        for item in title:
            fw.write("%s\n" % item)
    except OSError as e:
            print(e.errno)

if __name__ == '__main__':
    data = '../k-map/slide_layer/' + cid + '/' + chid + '.json'
    directory = '../k-map/title/' + cid + '/'
    if not os.path.exists(directory):
        os.makedirs(directory)
    write_title = directory + chid + '.txt'
    layer_one = paser_step_one(data, write_title)
