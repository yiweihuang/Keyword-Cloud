require 'http'
require 'url'
require 'json'

class PostKmap
  def self.call(chapter_id:, kmap_json:)
    kmap_json_string = kmap_json.split("\n")[0]
    parse_json = kmap_json_string.gsub!("'", "\"")
    uri = URI(ENV['Kmap'])
    res = Net::HTTP.post_form(uri, 'data' => parse_json, 'chapter_id' => chapter_id)
    JSON.parse(res.body)
  end
end
