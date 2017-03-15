require 'sequel'

Sequel.migration do
  change do
    create_table(:histories) do
      primary_key :id
      foreign_key :course_id, :courses

      Integer :chapter_id
      Integer :count
      Jsonb :history, null: false, default: '{}'
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
