Dir.glob('./{config,services,controllers,lib,models}/init.rb').each do |file|
  require file
end
run KeywordCloudAPI
