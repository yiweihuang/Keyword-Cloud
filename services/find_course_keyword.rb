class FindCourseKeyword
  def self.call(course_id:)
    directory_cid_name = "../Subtitle-Keyword/hot_word/" + course_id.to_s + "/"
    chid_arr = Dir.entries(directory_cid_name).select {|f| !File.directory? f}
    chid_arr.map do |chid|
      contents = File.read(directory_cid_name + chid)
      id = chid.split(".")[0].to_i
      [id, contents]
    end
  end
end
