require 'json'
require 'base64'
require 'sequel'

# Holds a full file file's information
class Subtitle < Sequel::Model
  plugin :uuid, field: :id

  plugin :timestamps, update_on_create: true
  set_allowed_columns :filename

  many_to_one :folders

  def document=(doc_plaintext)
    self.document_encrypted = SecureDB.encrypt(doc_plaintext) if doc_plaintext
  end

  def document
    SecureDB.decrypt(document_encrypted)
  end

  def to_json(options = {})
    doc = document ? Base64.strict_encode64(document) : nil
    JSON({  type: 'subtitles',
            id: id,
            data: {
              folder_id: folder_id,
              filename: filename,
              video_id: video_id,
              checksum: checksum,
              document_base64: doc,
              document: document
            }
          },
         options)
  end
end
