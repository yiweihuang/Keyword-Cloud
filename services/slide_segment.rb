require 'base64'

class SlideSegment
  def self.call(folder_id:)
    doc = SimpleFile.where(folder_id: folder_id)
                    .all
    fileInfo = doc.map do |s|
      plain = Base64.strict_decode64(s.document)
      decoded = plain.force_encoding('UTF-8')
      `python3 helpers/slide_segment.py "#{decoded}"`
    end
    fileInfo
  end
end
