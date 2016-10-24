# Create new file for a folder
class CreateFileForSubtitle
  def self.call(folder:, video_id:, filename:, document:)
    saved_file = folder.add_subtitle(filename: filename)
    saved_file.video_id = video_id
    saved_file.document = document
    saved_file.save
  end
end
