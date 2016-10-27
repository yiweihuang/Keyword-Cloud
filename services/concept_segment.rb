require 'base64'

class ConceptSegment
  def self.call(folder_id:)
    doc = SimpleFile.where(folder_id: folder_id)
                    .all
    fileInfo = doc.map do |s|
      plain = Base64.strict_decode64(s.document)
      concept = plain.force_encoding('UTF-8')
    end
    fileInfo
  end
end
