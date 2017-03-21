require 'base64'

class FindPdfParser < Sinatra::Base
  def self.call(course_id:, folder_id:, chapter_id:)
    all_file = SimpleFile.where(folder_id: folder_id).all
    all_file.map do |f|
      `python helpers/pdf_filter.py "#{course_id}" "#{chapter_id}"`
    end
  end
end
