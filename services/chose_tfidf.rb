# Create new file for a folder
class ChoseTfidf
  def self.call(course_id:, chapter_id:, top_tfidf:)
    ti = Tfidf.where(course_id: course_id, chapter_id: chapter_id).first
    ti.chose_word = top_tfidf
    ti.save
  end
end
