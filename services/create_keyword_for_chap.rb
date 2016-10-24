# Create new file for a folder
class CreateKeywordForChap
  def self.call(course_id:, folder_id:, chapter_id:, chapter_name:, folder_type:, priority:, keyword:)
    if Keyword.where(course_id: course_id, folder_id: folder_id, chapter_id: chapter_id).first != nil
      kw = Keyword.where(course_id: course_id, folder_id: folder_id, chapter_id: chapter_id).first
      kw.keyword = keyword
      kw.save
    else
      kw = Keyword.new()
      course = Course[course_id]
      kw.folder_id = folder_id
      kw.chapter_id = chapter_id
      kw.chapter_name = chapter_name
      kw.folder_type = folder_type
      kw.priority = priority
      kw.keyword = keyword
      course.add_course_keyword(kw)
    end
  end
end
