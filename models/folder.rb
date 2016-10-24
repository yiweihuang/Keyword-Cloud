require 'json'
require 'sequel'

# Holds a Folder's information
class Folder < Sequel::Model
  plugin :timestamps, update_on_create: true
  set_allowed_columns :name

  one_to_many :simple_files,
              class: :SimpleFile,
              key: :folder_id

  one_to_many :subtitles,
              class: :Subtitle,
              key: :folder_id

  many_to_one :courses, class: :Course

  plugin :association_dependencies, simple_files: :destroy

  def folder_url
    SecureDB.decrypt(folder_url_encrypted)
  end

  def folder_url=(folder_url_plaintext)
    self.folder_url_encrypted = SecureDB.encrypt(folder_url_plaintext) if folder_url_plaintext
  end

  def to_json(options = {})
    JSON({  type: 'folder',
            id: id,
            attributes: {
              folder_type: folder_type,
              course_id: course_id,
              chapter_id: chapter_id,
              chapter_order: chapter_order,
              name: name,
              folder_url: folder_url
            }
          },
         options)
  end
end
