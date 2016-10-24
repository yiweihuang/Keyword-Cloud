require 'mysql2'
require 'csv'

class FindChapterVideo
  def self.call(course_id:)
    directory_cid_name = "../Subtitle-Keyword/video_file/" + course_id.to_s + "/"
    Dir.mkdir(directory_cid_name) unless File.exists?(directory_cid_name)
    csv_path = directory_cid_name + "v_chapter_video.csv"
    db = Mysql2::Client.new(host: ENV['HOSTNAME'], username: ENV['USERNAME'],
                            password: ENV['PASSWORD'], database: ENV['DATABASE'])
    sql = "SELECT * FROM #{ENV['URL']} WHERE cid = #{course_id}"
    result = db.query(sql)
    CSV.open(csv_path , "w") do |csv|
      result.each do |chapInfo|
        csv << [chapInfo["cid"].to_s, chapInfo["chid"].to_s, chapInfo["chapter_order"].to_s,
                chapInfo["content_order"].to_s, chapInfo["vid"].to_s,
                chapInfo["name"], chapInfo["urls"]]
      end
    end
  end
end
