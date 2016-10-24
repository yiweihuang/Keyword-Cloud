require 'mysql2'

class FindCourseVideo
  def self.call(course_id:, chapter_id:, folder_id:)
    db = Mysql2::Client.new(host: ENV['HOSTNAME'], username: ENV['USERNAME'],
                            password: ENV['PASSWORD'], database: ENV['DATABASE'])
    sql = "SELECT chapter_order, content_order, vid, name, urls FROM #{ENV['URL']} WHERE cid = #{course_id} AND chid = #{chapter_id}"
    result = db.query(sql)
    result.each do |urlInfo|
      if Videourl.where(course_id: course_id, chapter_id: chapter_id, video_id: urlInfo['vid']).first != nil
        videourl = Videourl.where(course_id: course_id, chapter_id: chapter_id, video_id: urlInfo['vid']).first
      else
        videourl = Videourl.new()
        course = Course[course_id]
        videourl.chapter_id = chapter_id.to_i
        videourl.chapter_order = urlInfo['chapter_order']
        videourl.video_id = urlInfo['vid']
        videourl.video_order = urlInfo['content_order']
        videourl.name = urlInfo['name']
        videourl.video_url = urlInfo['urls']
        course.add_course_videourl(videourl)
      end
    end
    Videourl.where(course_id: course_id, chapter_id: chapter_id).all
  end
end
