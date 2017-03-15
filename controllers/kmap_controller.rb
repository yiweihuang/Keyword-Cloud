# show keyword
class KeywordCloudAPI < Sinatra::Base
  get '/api/v1/kmaps/:uid/:course_id' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      course_id = params[:course_id]
      halt 401 unless authorized_account?(env, uid)
      kmap_set = Tfidf.where(course_id: course_id, folder_type: 'slides').all
      kmap_info = kmap_set.map do |k|
        {
          'course_id' => k.course_id,
          'chapter_id' => k.chapter_id,
          'chapter_name' => k.chapter_name,
          'kmap' => k.tfidf,
          'range' => k.range
        }
      end
      JSON.pretty_generate(content: kmap_info)
    rescue => e
      logger.info "FAILED to connect sqlite: #{e}"
      halt 404
    end
  end

  get '/api/v1/kmaps/:uid/:course_id/makekmap' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      course_id = params[:course_id]
      halt 401 unless authorized_account?(env, uid)
      coursename = Course.where(id: course_id).first.course_name
      keyword = Hash.new
      slide_folder = Folder.where(course_id: course_id, folder_type: 'slides').all
      slideInfo = slide_folder.map do |f|
        keyword.merge!({f.id => SlideSegment.call(folder_id: f.id)})
        keyword[f.id]
      end
      concept_folder = Folder.where(course_id: course_id, folder_type: 'concepts').all
      conceptInfo = []
      concept_folder.map do |f|
        content = ConceptSegment.call(folder_id: f.id)
        if content.any?
          conceptInfo.push(content)
        end
      end
      info = keyword.map do |id, s|
        chapter_id = Folder[id].chapter_id
        folder_type = Folder[id].folder_type
        name = Folder[id].name
        if s.any?
          priority = 2
          json = SlideTfidf.call(arr: slideInfo, signal: s, type: 'kmap')
          if conceptInfo.any?
            json = SlideConceptMix.call(slide: json, concept: conceptInfo)
          end
        else
          if conceptInfo.any?
            priority = 3
            json = ConceptIdf.call(concept: conceptInfo)
          end
        end
        if json
          title_str = FindSlideTitle.call(course_id: course_id, chapter_id: chapter_id)
          range = FindRange.call(tfidf: json, title_str: title_str)
        end
        CreateTfidfForChap.call(
          course_id: course_id,
          folder_id: id,
          chapter_id: chapter_id,
          chapter_name: name,
          folder_type: folder_type,
          priority: priority,
          tfidf: json,
          range: range)
      end
      JSON.pretty_generate(data: coursename, content: info)
    rescue => e
      logger.info "FAILED to make keyword: #{e.inspect}"
      halt 404
    end
  end

  get '/api/v1/kmaps/:uid/:course_id/:chapter_id/:number/show' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      course_id = params[:course_id]
      chapter_id = params[:chapter_id]
      number = params[:number]
      halt 401 unless authorized_account?(env, uid)
      name = Course.where(id: course_id).first.course_name
      content = Tfidf.where(course_id: course_id, chapter_id: chapter_id, priority: 2).first
      title_str = FindSlideTitle.call(course_id: course_id, chapter_id: chapter_id)
      top_tfidf = FindTfidf.call(tfidf_detail: content, number: number, title_str: title_str)
      ChoseTfidf.call(
        course_id: course_id,
        chapter_id: chapter_id,
        top_tfidf: top_tfidf.to_json)

      JSON.pretty_generate(data: name,
                           course_id: content.course_id,
                           folder_id: content.folder_id,
                           chapter_id: content.chapter_id,
                           chapter_name: content.chapter_name,
                           range: content.range,
                           top_tfidf: top_tfidf)
    rescue => e
      logger.info "FAILED to show keyword: #{e.inspect}"
      halt 404
    end
  end

  post '/api/v1/kmaps/:uid/:course_id/:chapter_id/postkmap' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      course_id = params[:course_id]
      chapter_id = params[:chapter_id]
      halt 401 unless authorized_account?(env, uid)
      delete_kmap_arr = JSON.parse(request.body.read)
      DeleteKmap.call(course_id: course_id,
                      chapter_id: chapter_id,
                      delete_kmap: delete_kmap_arr['delete_kmap'])
      JSON.pretty_generate(status: 'succeed to modify keywords')
    rescue => e
      logger.info "FAILED to post kmap: #{e.inspect}"
      halt 404
    end
  end

  get '/api/v1/kmaps/:uid/:course_id/:chapter_id/show/kmap' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      course_id = params[:course_id]
      chapter_id = params[:chapter_id]
      halt 401 unless authorized_account?(env, uid)
      name = Course.where(id: course_id).first.course_name
      content = Tfidf.where(course_id: course_id, chapter_id: chapter_id, priority: 2).first
      kmap_json = CreateKmapTree.call(course_id: course_id, chapter_id: chapter_id, name: name, tfidf: content.chose_word)
      JSON.pretty_generate(data: name,
                           course_id: content.course_id,
                           folder_id: content.folder_id,
                           chapter_id: content.chapter_id,
                           chapter_name: content.chapter_name,
                           kmap_json: kmap_json)
    rescue => e
      logger.info "FAILED to show keyword: #{e.inspect}"
      halt 404
    end
  end
end
