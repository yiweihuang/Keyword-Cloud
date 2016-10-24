require 'base64'

class GetSubtitle
  def self.call(course_id:, folder_id:, chapter_id:)
    doc = Subtitle.where(folder_id: folder_id).all
    doc.map do |s|
      plain = Base64.strict_decode64(s.document)
      directory_cid_name = "../Subtitle-Keyword/subtitle_file/" + course_id.to_s + "/"
      Dir.mkdir(directory_cid_name) unless File.exists?(directory_cid_name)
      directory_name = "../Subtitle-Keyword/subtitle_file/" + course_id.to_s + "/" + chapter_id.to_s + "/"
      Dir.mkdir(directory_name) unless File.exists?(directory_name)
      txt_path = "../Subtitle-Keyword/subtitle_file/" + course_id.to_s + "/" + chapter_id.to_s + "/" + s.video_id.to_s + ".txt"
      File.open(txt_path, 'w') { |file| file.write(plain) }
      txt_path
    end
  end
end
