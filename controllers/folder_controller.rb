class KeywordCloudAPI < Sinatra::Base
  post '/api/v1/accounts/:uid/:course_id/:folder_type/?' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      halt 401 unless authorized_account?(env, uid)

      course_id = params[:course_id]
      folder_type = params[:folder_type]
      new_folder_data = JSON.parse(request.body.read)
      saved_folder = CreateFolderForCourse.call(
        course_id: course_id,
        folder_type: folder_type,
        folder_url: new_folder_data['folder_url'])
    rescue => e
      logger.info "FAILED to create new folder: #{e.inspect}"
      halt 400
    end

    status 201
    saved_folder.to_json
  end

  get '/api/v1/accounts/:uid/:course_id/:folder_type/?' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      course_id = params[:course_id]
      folder_type = params[:folder_type]
      halt 401 unless authorized_account?(env, uid)

      course_name = Course.where(id: course_id).first.course_name
      folder = Folder.where(course_id: course_id, folder_type: folder_type).all
      folderInfo = folder.map do |s|
        {
          'id' => s.id,
          'data' => {
            'course_id' => s.course_id,
            'folder_type' => s.folder_type,
            'chapter_order' => s.chapter_order,
            'chapter_id' => s.chapter_id,
            'name' => s.name,
            'folder_url_encrypted' => s.folder_url_encrypted
          }
        }
      end
      JSON.pretty_generate(course_name: course_name, data: folderInfo)
    rescue => e
      logger.info "FAILED to find chapter for course #{folder_type}: #{e}"
      halt 404
    end
  end
end
