class DeleteKeyword
  def self.call(course_id:, chapter_id:, delete_keyword:)
    current_keyword = Keyword.where(course_id: course_id,
                                    chapter_id: chapter_id,
                                    folder_type: 'slides').first.keyword
    delete_keyword = delete_keyword.map { |i| "'" + i.to_s + "'" }.join(",")
    new_keyword = `python3 helpers/delete_keyword.py "#{current_keyword}" "#{delete_keyword}"`
    keyword_modified = Keyword.where(course_id: course_id,
                                     chapter_id: chapter_id,
                                     folder_type: 'slides').first
    keyword_modified.keyword = new_keyword
    keyword_modified.save
  end
end
