class KeywordCloudAPI < Sinatra::Base
  post '/api/v1/accounts/:uid/:course_id/folders/:folder_id/files/?' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      halt 401 unless authorized_account?(env, uid)

      new_data = JSON.parse(request.body.read)
      folder = Folder[params[:folder_id]]
      saved_file = CreateFileForFolder.call(
        folder: folder,
        filename: new_data['filename'],
        document: new_data['document'],
        origin_document: new_data['origin_document'])
    rescue => e
      logger.info "FAILED to create new file: #{e.inspect}"
      halt 400
    end

    status 201
    saved_file.to_json
  end

  post '/api/v1/accounts/:uid/:course_id/folders/:folder_id/:video_id/files/?' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      halt 401 unless authorized_account?(env, uid)

      new_data = JSON.parse(request.body.read)
      video_id = params[:video_id]
      folder = Folder[params[:folder_id]]
      saved_file = CreateFileForSubtitle.call(
        folder: folder,
        video_id: video_id,
        filename: new_data['filename'],
        document: new_data['document'])
    rescue => e
      logger.info "FAILED to create new file: #{e.inspect}"
      halt 400
    end

    status 201
    saved_file.to_json
  end

  delete '/api/v1/accounts/:uid/:course_id/folders/:folder_id/files/?' do
    content_type 'application/json'
    begin
      folder_id = params[:folder_id]
      uid = params[:uid]
      halt 401 unless authorized_account?(env, uid)

      delete_info = JSON.parse(request.body.read)
      filename = delete_info['filename']
      file = SimpleFile.where(filename: filename,
                              folder_id: folder_id).first
      DeleteFile.call(
        file_id: file.id
      )
    rescue => e
      logger.info "FAILED to file: #{e.inspect}"
      halt 400
    end
    status 201
  end

  delete '/api/v1/accounts/:uid/:course_id/folders/:folder_id/:video_id/files/?' do
    content_type 'application/json'
    begin
      folder_id = params[:folder_id]
      video_id = params[:video_id]
      uid = params[:uid]
      halt 401 unless authorized_account?(env, uid)

      delete_info = JSON.parse(request.body.read)
      filename = delete_info['filename']
      file = Subtitle.where(filename: filename,
                            folder_id: folder_id,
                            video_id: video_id).first
      DeleteSubtitle.call(
        file_id: file.id
      )
    rescue => e
      logger.info "FAILED to file: #{e.inspect}"
      halt 400
    end
    status 201
  end

  post '/api/v1/accounts/:uid/:course_id/folders/:folder_id/?' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      halt 401 unless authorized_account?(env, uid)
      chapter_id = Folder[params[:folder_id]].chapter_id
      course_video_url = FindCourseVideo.call(
        course_id: params[:course_id],
        chapter_id: chapter_id,
        folder_id: params[:folder_id])

    rescue => e
      logger.info "FAILED to create new file: #{e.inspect}"
      halt 400
    end

    status 201
    course_video_url.to_json
  end

  get '/api/v1/accounts/:uid/:course_id/folders/:folder_id' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      course_id = params[:course_id]
      folder_id = params[:folder_id]
      halt 401 unless authorized_account?(env, uid)
      folder_name = Folder.where(id: folder_id).first.name
      folder_type = Folder.where(id: folder_id).first.folder_type
      if folder_type == 'subtitles'
        subtitle = Subtitle.where(folder_id: folder_id).all
        fileInfo = subtitle.map do |s|
          {
            'id' => s.id,
            'data' => {
              'filename' => s.filename,
              'video_id' => s.video_id,
              'document_encrypted' => s.document_encrypted,
              'checksum' => s.checksum
            }
          }
        end
      elsif
        simplefile = SimpleFile.where(folder_id: folder_id).all
        fileInfo = simplefile.map do |s|
          {
            'id' => s.id,
            'data' => {
              'filename' => s.filename,
              'document_encrypted' => s.document_encrypted,
              'checksum' => s.checksum
            }
          }
        end
      end
      JSON.pretty_generate(course_id: course_id, folder_name: folder_name, folder_id: folder_id, folder_type: folder_type, data: fileInfo)
    rescue => e
      logger.info "FAILED to find file for chapter #{folder_id}: #{e}"
      halt 404
    end
  end

  get '/api/v1/accounts/:uid/:course_id/folders/:folder_id/files/:file_id/?' do
    content_type 'application/json'

    begin
      doc_url = URI.join(@request_url.to_s + '/', 'document')
      file = SimpleFile.where(folder_id: params[:folder_id], id: params[:file_id])
                       .first
      halt(404, 'Files not found') unless file
      JSON.pretty_generate(data: {
                             file: file,
                             links: { document: doc_url }
                           })
    rescue => e
      status 400
      logger.info "FAILED to process GET file(concepts & sildes) request: #{e.inspect}"
      e.inspect
    end
  end

  get '/api/v1/accounts/:uid/:course_id/folders/:folder_id/:video_id/files/:file_id/?' do
    content_type 'application/json'

    begin
      doc_url = URI.join(@request_url.to_s + '/', 'document')
      file = Subtitle.where(folder_id: params[:folder_id], id: params[:file_id])
                     .first
      halt(404, 'Files not found') unless file
      JSON.pretty_generate(data: {
                             file: file,
                             links: { document: doc_url }
                           })
    rescue => e
      status 400
      logger.info "FAILED to process GET file(subtitles) request: #{e.inspect}"
      e.inspect
    end
  end

  # get '/api/v1/accounts/:uid/:course_id/folders/:folder_id/files/:file_id/document' do
  #   content_type 'text/plain'
  #
  #   begin
  #     SimpleFile.where(folder_id: params[:folder_id], id: params[:file_id])
  #               .first
  #               .document
  #     # GetFileContent.call(id: params[:file_id], folder_id: params[:folder_id])
  #   rescue => e
  #     logger.info "FAILED to process GET file(concepts & sildes) document: #{e.inspect}"
  #     halt 404
  #   end
  # end
  #
  # get '/api/v1/accounts/:uid/:course_id/folders/:folder_id/:video_id/files/:file_id/document' do
  #   content_type 'text/plain'
  #
  #   begin
  #     Subtitle.where(folder_id: params[:folder_id], id: params[:file_id])
  #             .first
  #             .document
  #     # GetFileContent.call(id: params[:file_id], folder_id: params[:folder_id])
  #   rescue => e
  #     logger.info "FAILED to process GET file(subtitles) document: #{e.inspect}"
  #     halt 404
  #   end
  # end
end
