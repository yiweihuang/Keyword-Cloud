require 'sequel'
require 'json'

# Holds and persists an account's information
class Course < Sequel::Model
  one_to_many :course_folders,
               class: :Folder,
               key: :course_id

  one_to_many :course_videourls,
               class: :Videourl,
               key: :course_id

  one_to_many :course_keywords,
               class: :Keyword,
               key: :course_id

  def to_json(options = {})
    JSON({  type: 'courses',
            id: id,
            course_name: course_name
          },
         options)
  end
end
