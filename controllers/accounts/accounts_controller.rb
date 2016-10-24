# show authorized courses of the account
class KeywordCloudAPI < Sinatra::Base
  get '/api/v1/accounts/:uid' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      halt 401 unless authorized_account?(env, uid)
      courseInfo = FindCourseAuth.call(uid: uid.to_i)
      JSON.pretty_generate(data: courseInfo)
    rescue => e
      logger.info "FAILED to find authorized courses for account: #{e}"
      halt 404
    end
  end

  get '/api/v1/accounts/:uid/:course_id' do
    content_type 'application/json'
    begin
      uid = params[:uid]
      course_id = params[:course_id]
      halt 401 unless authorized_account?(env, uid)
      name = Course.where(id: course_id).first.course_name
      JSON.pretty_generate(data: name)
    rescue => e
      logger.info "FAILED to find authorized courses for account: #{e}"
      halt 404
    end
  end
end
