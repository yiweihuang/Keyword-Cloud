require 'csv'
# require 'json'

class KmapToDiscussion
  def self.call(course_id:, chapter_id:, tfidf:)
    kmap_info = Hash.new
    kmap_point = JSON.parse(tfidf).keys
    db = Mysql2::Client.new(host: ENV['HOSTNAME'], username: ENV['USERNAME'],
                            password: ENV['PASSWORD'], database: ENV['DATABASE'])
    sql = "SELECT id, title FROM #{ENV['DISCUSSION']} WHERE cid = #{course_id}"
    result = db.query(sql)
    kmap_point.map do |word|
      temp_arr = []
      result.each do |discuss|
        temp_hash = Hash.new
        if discuss["title"].include? word
          temp_hash[discuss["title"]] = discuss["id"]
          temp_arr.push(temp_hash)
        end
      end
      kmap_info[word] = temp_arr
    end
    kmap_info
  end
end
