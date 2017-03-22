class FindTfidf
  def self.call(tfidf_detail:, number:, title_str:)
    temp_tfidf = Hash.new
    word_freq = `python3 helpers/top_number.py "#{tfidf_detail.tfidf}" "#{number}" "#{title_str}"`
    puts word_freq
    arr = word_freq.split("\n")
    title_arr = title_str.split(",")
    title_arr.map do |t_arr|
      temp_tfidf[t_arr] = "title"
    end
    if arr
      arr.map do |i|
        key_value = i.split("(")[1].split(")")[0].split(", ")
        temp_tfidf[key_value[0].gsub("'", '')] = key_value[1]
      end
    end
    temp_tfidf
  end
end
