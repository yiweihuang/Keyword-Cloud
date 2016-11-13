require 'sinatra'

class KeywordCloudAPI < Sinatra::Base
  get '/api/v1/mongo/:course_id' do
    content_type 'application/json'
    begin
      FindVideoRecord.call(course_id: params[:course_id])
      JSON.pretty_generate(status: 'mongo success')
    rescue => e
      logger.info "FAILED to connect mongodb: #{e}"
      halt 404
    end
  end

  get '/api/v1/videos' do
    content_type 'application/json'
    begin
      course_arr = Folder.select(:course_id).map(&:course_id).uniq
      course_arr.map do |id|
        FindChapterVideo.call(course_id: id)
      end
      JSON.pretty_generate(data: 'videos success')
    rescue => e
      logger.info "FAILED to get chapter video: #{e}"
      halt 404
    end
  end

  get '/api/v1/courses/subtitles/:course_id' do
    content_type 'application/json'
    begin
      course_id = params[:course_id]
      coursename = Course.where(id: course_id).first.course_name
      keyword = Hash.new
      chap_folder = Folder.where(course_id: params[:course_id], folder_type: 'subtitles').all
      folderInfo = chap_folder.map do |f|
        keyword.merge!({f.id => GetSubtitle.call(course_id: course_id, folder_id: f.id, chapter_id: f.chapter_id)})
        keyword[f.id]
      end
      JSON.pretty_generate(data: coursename, path: folderInfo)
    rescue => e
      logger.info "FAILED to download subtitles: #{e.inspect}"
      halt 404
    end
  end

  get '/api/v1/mix/:course_id' do
    content_type 'application/json'
    begin
      course_id = params[:course_id]
      # coursename = Course.where(id: course_id).first.course_name
      chid = FindCourseKeyword.call(course_id: course_id)
      keywordInfo = chid.map do |id, contents|
        folderInfo = Folder.where(course_id: course_id, chapter_id: id, folder_type: 'subtitles').first
        if Keyword.where(chapter_id: id, folder_type: 'slides').first != nil
          slide_keyword = Keyword.where(chapter_id: id, folder_type: 'slides').first.keyword
          json = CreateFinalKeyword.call(slide_keyword: slide_keyword, subtitle_keyword: contents)
          CreateKeywordForChap.call(
            course_id: course_id,
            folder_id: folderInfo.id,
            chapter_id: id,
            chapter_name: folderInfo.name,
            folder_type: 'subtitles',
            priority: 1,
            keyword: json)
        else
          json = CreateFinalKeyword.call(slide_keyword: 'empty', subtitle_keyword: contents)
          CreateKeywordForChap.call(
            course_id: course_id,
            folder_id: folderInfo.id,
            chapter_id: id,
            chapter_name: folderInfo.name,
            folder_type: 'subtitles',
            priority: 1,
            keyword: json)
        end
      end
      JSON.pretty_generate(data: keywordInfo)
    rescue => e
      logger.info "FAILED to make keyword: #{e.inspect}"
      halt 404
    end
  end

  get '/api/v1/courses/keywords' do
    content_type 'application/json'
    begin
      course_id = Keyword.select(:course_id).map(&:course_id).uniq
      JSON.pretty_generate(data: course_id)
    rescue => e
      logger.info "FAILED to connect sqlite: #{e}"
      halt 404
    end
  end

  get '/api/v1/shellscript' do
    content_type 'application/json'
    begin
      folder_id = Subtitle.select(:folder_id).map(&:folder_id).uniq
      course_id = folder_id.map do |id|
        Folder.where(id: id).first.course_id
      end
      course_id = course_id.uniq
      # course_id = Folder.select(:course_id).map(&:course_id).uniq
      shell_array = course_id.map { |i| i.to_s }.join(" ")
      JSON.pretty_generate(data: shell_array)
    rescue => e
      logger.info "FAILED to connect sqlite: #{e}"
      halt 404
    end
  end

  get '/api/v1/courses/keywords/:course_id' do
    content_type 'application/json'
    begin
      course_id = params[:course_id]
      keyword_record = Keyword.where(course_id: course_id).all
      keywordInfo = keyword_record.map do |k|
        {
          'id' => k.id,
          'chapter_id' => k.chapter_id,
          'chapter_name' => k.chapter_name,
          'folder_type' => k.folder_type,
          'priority' => k.priority,
          'keyword' => k.keyword
        }
      end
      JSON.pretty_generate(status: keywordInfo)
    rescue => e
      logger.info "FAILED to get keyword: #{e}"
      halt 404
    end
  end
end
