require 'sequel'

Sequel.migration do
  change do
    create_table(:simple_files) do
      String :id, type: :uuid, primary_key: true
      foreign_key :folder_id, :folders

      String :filename
      String :document_encrypted, text: true
      String :ori_document_encrypted, text: true
      String :checksum, unique: true, text: true
      DateTime :created_at
      DateTime :updated_at

    end
  end
end
