# GoodJob.configure do |config|
#   config.execution_mode = :async
# end
Rails.application.configure do
  config.good_job.enable_cron = true
end
