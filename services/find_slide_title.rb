class FindSlideTitle
  def self.call(course_id:, chapter_id:)
    course_json = "../k-map/title/" + course_id.to_s + "/" + chapter_id.to_s + ".txt"
    File.read(course_json).split("\n").join(",")
  end
end
