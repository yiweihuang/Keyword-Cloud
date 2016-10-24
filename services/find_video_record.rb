require 'sinatra'
require 'mongo'
require 'csv'

# 目前用course_id = 848
# 只抓出action = "seek"的資料然後寫成.csv檔，再存到mongodb的資料夾
# 之後還要修改：資料筆數、以及不需要用chapter_id

class FindVideoRecord < Sinatra::Base
  def self.call(course_id:)
    Mongo::Logger.logger.level = ::Logger::FATAL
    db = Mongo::Client.new( ENV['MONGODB_HOSTNAME'], :database => ENV['MONGODB_DATABASE'])
    data = db[ENV['MONGODB_COLLECTION_NAME']]
           .find({'courseId' => course_id.to_i,
                  'action' => 'seek'
                  }).to_a
    directory_name = "../Subtitle-Keyword/video_file/" + course_id.to_s
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    csv_path = "../Subtitle-Keyword/video_file/" + course_id.to_s + "/video_record.csv"

    CSV.open(csv_path , "w") do |csv|
      csv << ["userId", "videoStartTime", "videoEndTime", "videoTotalTime","videoId","time"]
      data.each do |data_tmp|
        csv << [data_tmp["userId"], data_tmp["videoStartTime"], data_tmp["videoEndTime"], data_tmp["videoTotalTime"], data_tmp["videoId"], data_tmp["time"].iso8601]
      end
    end
    csv_path
  end
end
