class CreateKmapTree
  def self.call(course_id:, chapter_id:, name:, tfidf:)
    kmap_point = JSON.parse(tfidf).keys
    kmap_point = kmap_point.map { |i| "'" + i.to_s + "'" }.join(",")
    if course_id == '908'
      `python3 helpers/kmap_tree_for_outline.py "#{course_id}" "#{chapter_id}" "#{name}" "#{kmap_point}"`
    else
      `python3 helpers/kmap_tree.py "#{course_id}" "#{chapter_id}" "#{name}" "#{kmap_point}"`
    end
  end
end
