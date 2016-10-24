# Service object to create new File using all columns
class DeleteFile
  def self.call(file_id:)
    file = SimpleFile[file_id]
    file.delete
  end
end
