require 'json'
require 'sequel'

# Holds a History's information
class History < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :courses, class: :Course

  def to_json(options = {})
    JSON({  type: 'history',
            id: id,
            attributes: {
              course_id: course_id,
              chapter_id: chapter_id,
              count: count,
              history: history
            }
          },
         options)
  end
end
