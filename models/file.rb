require 'json'
require 'base64'
require 'sequel'

# Holds a full file file's information
class SimpleFile < Sequel::Model
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

  def ori_document=(ori_doc_plaintext)
    self.ori_document_encrypted = SecureDB.encrypt(ori_doc_plaintext) if ori_doc_plaintext
  end

  def ori_document
    SecureDB.decrypt(ori_document_encrypted)
  end

  def to_json(options = {})
    doc = document ? Base64.strict_encode64(document) : nil
    ori_doc = ori_document ? Base64.strict_encode64(ori_document) : nil
    JSON({  type: 'files',
            id: id,
            data: {
              folder_id: folder_id,
              filename: filename,
              checksum: checksum,
              document_base64: doc,
              document: document,
              ori_document_base64: ori_doc,
              ori_document: ori_document
            }
          },
         options)
  end
end
