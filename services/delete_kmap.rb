class DeleteKmap
  def self.call(course_id:, chapter_id:, delete_kmap:)
    current_kmap = Tfidf.where(course_id: course_id,
                               chapter_id: chapter_id,
                               folder_type: 'slides').first.chose_word
    current_kmap = JSON.parse(current_kmap)
    delete_kmap.each { |k| current_kmap.delete k }
    kmap_modified = Tfidf.where(course_id: course_id,
                                chapter_id: chapter_id,
                                folder_type: 'slides').first

    kmap_modified.chose_word = current_kmap.to_json
    kmap_modified.save
    if History.where(course_id: course_id, chapter_id: chapter_id).first != nil
      histories = History.where(course_id: course_id, chapter_id: chapter_id)
      count = histories.count(:chapter_id)
      his_new = History.new()
      his_new.course_id = course_id
      his_new.chapter_id = chapter_id
      his_new.history = current_kmap.to_json
      his_new.count = count + 1
      his_new.save
    else
      his = History.new()
      his.course_id = course_id
      his.chapter_id = chapter_id
      his.history = current_kmap.to_json
      his.count = 1
      his.save
    end
  end
end
