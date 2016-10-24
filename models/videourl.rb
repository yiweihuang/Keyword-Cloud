require 'json'
require 'sequel'

# Holds a Folder's information
class Videourl < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :course, class: :Course

  def to_json(options = {})
    JSON({  type: 'url',
            id: id,
            attributes: {
              course_id: course_id,
              chapter_id: chapter_id,
              chapter_order: chapter_order,
              video_id: video_id,
              video_order: video_order,
              name: name,
              video_url: video_url
            }
          },
         options)
  end
end
