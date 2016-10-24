# Service object to create new File using all columns
class DeleteSubtitle
  def self.call(file_id:)
    file = Subtitle[file_id]
    file.delete
  end
end
