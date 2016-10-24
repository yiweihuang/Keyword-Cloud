import pandas as pd
import numpy as np
import dateutil.parser as dp


def filter_rawdata(path):
    df = pd.read_csv(path, sep=',')
    users = df.userId.unique()
    new_df = []
    for i in range(len(users)):
        drop = []
        filtered = df[(df['userId'] == users[i])]
        filtered = filtered.reset_index(drop=True)

        for j in range(len(filtered)):
            next_i = j + 1
            if next_i >= len(filtered):
                break
            this_time = dp.parse(filtered['time'][j]).replace(tzinfo=None)
            next_time = dp.parse(filtered['time'][next_i]).replace(tzinfo=None)
            duration = next_time - this_time
            duration_sec = duration.seconds
            if duration_sec < 2:
                drop.append(j)
        new_filtered = filtered.drop(filtered.index[drop])
        new_df.append(new_filtered)
    result = pd.concat(new_df).reset_index(drop=True)
    return result


def vid_dict(result):
    vid_dict = {}
    timeSequence = 14  # every 14 second is a sequence
    vid_list = result.videoId.unique()
    for i in range(len(vid_list)):
        time_count = {}
        data = []
        filtered = result[(result['videoId'] == vid_list[i])]
        filtered = filtered.reset_index(drop=True)
        # count sequence num
        totalSeq = round(float(filtered['videoTotalTime'][0])/timeSequence)
        for j in range(len(filtered)):
            videoEndTime = filtered['videoEndTime'][j]
            ratio = round(float(videoEndTime)) / timeSequence
            remain = round(float(videoEndTime)) % timeSequence
            if remain > 0:
                ratio = round(ratio + 1)
            # compute count
            if time_count.get(ratio) is None:
                time_count[ratio] = 1
            else:
                time_count[ratio] += 1

        for num in range(int(totalSeq + 2)):
            if time_count.get(num) is None:
                data.append([timeSequence * num, 0])
            else:
                data.append([timeSequence * num, time_count[num]])

        columns = ['time', 'count']
        data = np.array(data)
        vid_df = pd.DataFrame(data, columns=columns)
        vid_dict[vid_list[i]] = vid_df
    return vid_dict
