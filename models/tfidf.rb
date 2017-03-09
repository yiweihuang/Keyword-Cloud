require 'json'
require 'sequel'

# Holds a Folder's information
class Tfidf < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :courses, class: :Course

  def to_json(options = {})
    JSON({  type: 'tfidf',
            id: id,
            attributes: {
              course_id: course_id,
              folder_id: folder_id,
              priority: priority,
              folder_type: folder_type,
              chapter_id: chapter_id,
              chapter_name: chapter_name,
              tfidf: tfidf
            }
          },
         options)
  end
end
