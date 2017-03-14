# Create new file for a folder
class CreateTfidfForChap
  def self.call(course_id:, folder_id:, chapter_id:, chapter_name:, folder_type:, priority:, tfidf:, range:)
    if Tfidf.where(course_id: course_id, folder_id: folder_id, chapter_id: chapter_id).first != nil
      ti = Tfidf.where(course_id: course_id, folder_id: folder_id, chapter_id: chapter_id).first
      ti.tfidf = tfidf
      ti.range = range
      ti.save
    else
      ti = Tfidf.new()
      # course = Course[course_id]
      ti.course_id = course_id
      ti.folder_id = folder_id
      ti.chapter_id = chapter_id
      ti.chapter_name = chapter_name
      ti.folder_type = folder_type
      ti.priority = priority
      ti.tfidf = tfidf
      ti.range = range
      # course.add_course_tfidf(ti)
      ti.save
    end
  end
end
