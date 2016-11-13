class CreateFinalKeyword
  def self.call(slide_keyword:, subtitle_keyword:)
    if slide_keyword == 'empty'
      subtitle_keyword = subtitle_keyword.gsub!("\"", "'")
      `python3 helpers/mix_keyword.py "#{slide_keyword}" "#{subtitle_keyword}"`
    else
      subtitle_keyword = subtitle_keyword.gsub!("\"", "'")
      `python3 helpers/mix_keyword.py "#{slide_keyword}" "#{subtitle_keyword}"`
    end
  end
end
