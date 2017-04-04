class ReadTfidf
  def self.call(course_id:)
    all_keyword = Hash.new
    tfidf_result = "../k-map/result/" + course_id.to_s + "/"
    chid_arr = Dir.entries(tfidf_result).select {|f| !File.directory? f}
    chid_arr.map do |chid|
      keyword = Hash.new
      id = chid.split(".")[0].to_i
      File.open(tfidf_result + chid, "r").each_line do |contents|
        word, tfidf = contents.split("\t")
        keyword[word] = tfidf.delete!("\n")
      end
      all_keyword[id] = keyword
    end
    all_keyword
  end
end
