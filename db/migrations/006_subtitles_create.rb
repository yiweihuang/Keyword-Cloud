require 'sequel'

Sequel.migration do
  change do
    create_table(:subtitles) do
      String :id, type: :uuid, primary_key: true
      foreign_key :folder_id, :folders

      String :filename
      Integer :video_id
      String :document_encrypted, text: true
      String :checksum, unique: true, text: true
      DateTime :created_at
      DateTime :updated_at

    end
  end
end
