class FindRange
  def self.call(tfidf:, title_str:)
    `python3 helpers/tfidf_range.py "#{tfidf}" "#{title_str}"`
  end
end
