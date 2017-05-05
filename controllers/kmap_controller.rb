# show keyword
class KeywordCloudAPI < Sinatra::Base
  get '/api/v1/kmaps/:uid/:course_id' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      course_id = params[:course_id]
      halt 401 unless authorized_account?(env, uid)
      kmap_set = Tfidf.where(course_id: course_id, folder_type: 'slides').all
      order_kmap = Hash.new
      kmap_set.map do |k|
        order_kmap[k.folder_id]=
          {
            'course_id' => k.course_id,
            'chapter_id' => k.chapter_id,
            'chapter_name' => k.chapter_name,
            'kmap' => k.tfidf,
            'range' => k.range
          }
      end
      order_kmap = Hash[ order_kmap.sort_by { |key, val| key.to_s } ]
      kmap_info = order_kmap.map do |key, content|
        content
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
      # Slide
      SlideTfidf.call(course_id: course_id, type: 'kmap')
      keyword = ReadTfidf.call(course_id: course_id)

      concept_folder = Folder.where(course_id: course_id, folder_type: 'concepts').all
      conceptInfo = Hash.new
      concept_folder.map do |f|
        if !ConceptSegment.call(folder_id: f.id).empty?
          content = ConceptSegment.call(folder_id: f.id)
          if content.any?
            conceptInfo_arr = []
            conceptInfo_arr.push(content)
          end
          conceptInfo.merge!({f.chapter_id => conceptInfo_arr})
        end
      end

      if !keyword.empty? and !conceptInfo.empty?
        info = keyword.map do |id, s|
          folder_id = Folder.where(chapter_id: id, folder_type:'slides').first.id
          folder_type = Folder[folder_id].folder_type
          name = Folder[folder_id].name
          if s.any?
            priority = 2
            json = ConvertJson.call(cid: course_id, chid: id)
            if !conceptInfo[id].nil?
              json = SlideConceptMix.call(slide: json, concept: conceptInfo[id])
            end
          end
          if json
            title_str = FindSlideTitle.call(course_id: course_id, chapter_id: id)
            range = FindRange.call(tfidf: json, title_str: title_str)
          end
          CreateTfidfForChap.call(
            course_id: course_id,
            folder_id: id,
            chapter_id: id,
            chapter_name: name,
            folder_type: folder_type,
            priority: priority,
            tfidf: json,
            range: range)
        end
      elsif !conceptInfo.empty? and keyword.empty?
        info = conceptInfo.map do |id, s|
          folder_id = Folder.where(chapter_id: id, folder_type:'concepts').first.id
          name = Folder[id].name
          if s.any?
            priority = 2
            json = ConceptIdf.call(concept: conceptInfo[id])
          end
          if json
            title_str = FindSlideTitle.call(course_id: course_id, chapter_id: chapter_id)
            range = FindRange.call(tfidf: json, title_str: title_str)
          end
          CreateTfidfForChap.call(
            course_id: course_id,
            folder_id: folder_id,
            chapter_id: id,
            chapter_name: name,
            folder_type: 'slides',
            priority: priority,
            tfidf: json,
            range: range)
        end
      elsif !keyword.empty? and conceptInfo.empty?
        info = keyword.map do |id, s|
          folder_id = Folder.where(chapter_id: id, folder_type:'slides').first.id
          folder_type = Folder[folder_id].folder_type
          name = Folder[folder_id].name
          if s.any?
            priority = 2
            json = ConvertJson.call(cid: course_id, chid: id)
          end
          if json
            title_str = FindSlideTitle.call(course_id: course_id, chapter_id: id)
            range = FindRange.call(tfidf: json, title_str: title_str)
          end
          CreateTfidfForChap.call(
            course_id: course_id,
            folder_id: folder_id,
            chapter_id: id,
            chapter_name: name,
            folder_type: folder_type,
            priority: priority,
            tfidf: json,
            range: range)
        end
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
      ch_name = Folder.where(course_id: course_id, chapter_id: chapter_id).first.name
      content = Tfidf.where(course_id: course_id, chapter_id: chapter_id, priority: 2).first
      kmap_json = CreateKmapTree.call(course_id: course_id, chapter_id: chapter_id, name: ch_name, tfidf: content.chose_word)
      kmap_video_info = KmapToVideo.call(course_id: course_id, chapter_id: chapter_id,tfidf: content.chose_word)
      kmap_discussion_info = KmapToDiscussion.call(course_id: course_id, chapter_id: chapter_id,tfidf: content.chose_word)
      url = PostKmap.call(course_id: course_id, chapter_id: chapter_id, kmap_json: kmap_json, kmap_video_info: kmap_video_info, kmap_discussion_info: kmap_discussion_info)
      JSON.pretty_generate(data: name,
                           course_id: content.course_id,
                           folder_id: content.folder_id,
                           chapter_id: content.chapter_id,
                           chapter_name: content.chapter_name,
                           kmap_json: kmap_json,
                           url: url['url'])
    rescue => e
      logger.info "FAILED to show keyword: #{e.inspect}"
      halt 404
    end
  end
end
