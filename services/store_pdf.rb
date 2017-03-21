require 'base64'
require "prawn"

class StorePdf < Sinatra::Base
  def self.call(course_id:, folder_id:, chapter_id:)
    all_file = SimpleFile.where(folder_id: folder_id).all
    location = "../k-map/slide/#{course_id}"
    filename = chapter_id.to_s
    filename = filename + '.pdf'
    Dir.mkdir(location) unless File.exists?(location)
    all_file.map do |f|
      plain = Base64.strict_decode64(f.ori_document)
      File.delete("#{location}/#{filename}") if File.exist?("#{location}/#{filename}")
      File.open("#{location}/#{filename}", 'w') {|fr| fr.write(plain)}
    end
  end
end
