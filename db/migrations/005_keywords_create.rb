require 'sequel'

Sequel.migration do
  change do
    create_table(:keywords) do
      primary_key :id
      foreign_key :course_id, :courses

      Integer :folder_id
      Integer :chapter_id
      String :chapter_name
      String :folder_type
      Integer :priority
      String :keyword
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
