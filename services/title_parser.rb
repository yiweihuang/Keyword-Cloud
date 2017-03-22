require 'base64'

class TitleParser < Sinatra::Base
  def self.call(course_id:, chapter_id:)
    `python3 helpers/title_parse.py "#{course_id}" "#{chapter_id}"`
  end
end
