require_relative '../config/environment'
Rails.application.eager_load!
Rails.application.configure do
  path = "#{Rails.root}/log/cable.log"
  config.logger = ActiveSupport::Logger.new(path)
  ActionCable.server.config.logger = ActiveSupport::Logger.new(path)
end
 
run ActionCable.server
