require 'csv'
# require 'json'

class KmapToVideo
  def self.call(course_id:, chapter_id:, tfidf:)
    kmap_info = Hash.new
    kmap_point = JSON.parse(tfidf).keys
    csv_path = "../Subtitle-Keyword/video_file/" + course_id.to_s + "/v_chapter_video.csv"
    kmap_point.map do |word|
      temp_arr = []
      CSV.foreach(csv_path) do |row|
        temp_hash = Hash.new
        if row[5].include? word
          sc_url = "http://www.sharecourse.net/sharecourse/course/content/chapter/" + course_id.to_s + "?chid=" + row[1].to_s + "&vid="+ row[4].to_s
          temp_hash[row[5]] = sc_url
          temp_arr.push(temp_hash)
        end
      end
      kmap_info[word] = temp_arr
    end
    # course_json = "../k-map/987/" + chapter_id.to_s + ".json"
    # File.open(course_json,"w") do |f|
    #   f.write(kmap_info.to_json)
    # end
    kmap_info
  end
end
