class ErrorLogJob < ApplicationJob
  queue_as :error_log

  def perform(attributes = {})
    begin
      logs = `cat /var/www/afu-backend/current/log/production.log | grep '#{attributes[:uuid]}'`.split("\n")
      attributes[:data] = logs
    rescue
    end
    Log::Error.create!(attributes)
  end
end
