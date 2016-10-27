# show keyword
class KeywordCloudAPI < Sinatra::Base
  get '/api/v1/accounts/:uid/:course_id/:chapter_id/makekeyword' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      course_id = params[:course_id]
      halt 401 unless authorized_account?(env, uid)
      coursename = Course.where(id: course_id).first.course_name
      keyword = Hash.new
      slide_folder = Folder.where(course_id: params[:course_id], chapter_id: params[:chapter_id], folder_type: 'slides').all
      slideInfo = slide_folder.map do |f|
        keyword.merge!({f.id => SlideSegment.call(folder_id: f.id)})
        keyword[f.id]
      end
      concept_folder = Folder.where(course_id: params[:course_id], chapter_id: params[:chapter_id], folder_type: 'concepts').all
      conceptInfo = []
      concept_folder.map do |f|
        content = ConceptSegment.call(folder_id: f.id)
        if content.any?
          conceptInfo.push(content)
        end
      end
      info = keyword.map do |id, s|
        if s.any?
          chapter_id = Folder[id].chapter_id
          folder_type = Folder[id].folder_type
          priority = 2
          json = SlideTfidf.call(arr: slideInfo, signal: s)
          if conceptInfo.any?
            json = SlideConceptMix.call(slide: json, concept: conceptInfo)
          end
          name = Folder[id].name
          CreateKeywordForChap.call(
            course_id: course_id,
            folder_id: id,
            chapter_id: chapter_id,
            chapter_name: name,
            folder_type: folder_type,
            priority: priority,
            keyword: json)
        end
      end
      JSON.pretty_generate(data: coursename, content: info)
    rescue => e
      logger.info "FAILED to make keyword: #{e.inspect}"
      halt 404
    end
  end

  get '/api/v1/keywords/:uid/:course_id' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      course_id = params[:course_id]
      halt 401 unless authorized_account?(env, uid)
      # course_id = Keyword.where(course_id: course_id).select(:chapter_id).map(&:chapter_id).uniq
      keyword_set = Keyword.where(course_id: course_id, folder_type: 'slides').all
      keyword_info = keyword_set.map do |k|
        {
          'course_id' => k.course_id,
          'chapter_id' => k.chapter_id,
          'chapter_name' => k.chapter_name,
          'keyword' => k.keyword
        }
      end
      JSON.pretty_generate(content: keyword_info)
    rescue => e
      logger.info "FAILED to connect sqlite: #{e}"
      halt 404
    end
  end

  get '/api/v1/accounts/:uid/:course_id/:chapter_id/showkeyword' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      course_id = params[:course_id]
      chapter_id = params[:chapter_id]
      halt 401 unless authorized_account?(env, uid)
      name = Course.where(id: course_id).first.course_name
      content = Keyword.where(course_id: course_id, chapter_id: chapter_id, priority: 2).first
      JSON.pretty_generate(data: name, content: content)
    rescue => e
      logger.info "FAILED to show keyword: #{e.inspect}"
      halt 404
    end
  end

  post '/api/v1/accounts/:uid/:course_id/:chapter_id/postkeyword' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      course_id = params[:course_id]
      chapter_id = params[:chapter_id]
      halt 401 unless authorized_account?(env, uid)
      delete_keyword_arr = JSON.parse(request.body.read)
      DeleteKeyword.call(course_id: course_id,
                         chapter_id: chapter_id,
                         delete_keyword: delete_keyword_arr['delete_keyword'])
      JSON.pretty_generate(status: 'succeed to modify keywords')
    rescue => e
      logger.info "FAILED to post keyword: #{e.inspect}"
      halt 404
    end
  end
end
