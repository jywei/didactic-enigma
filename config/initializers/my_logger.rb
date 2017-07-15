module MyLogger
  class MyMiddleware
    def initialize(app)
      @app               = app
      @default_logger    = ActiveSupport::Logger.new("#{Rails.root}/log/#{Rails.env}.log")
      @controller_logger = ActiveSupport::Logger.new("#{Rails.root}/log/controllers.log")
      @channel_logger    = ActiveSupport::Logger.new("#{Rails.root}/log/channels.log")
    end

    def call(env)
      case 
      when env["HTTP_UPGRADE"] == 'websocket'
        Rails.logger = @channel_logger
      when env['PATH_INFO'].include?("/api/v1/")
        Rails.logger = @controller_logger
      else
        Rails.logger = @default_logger
      end
      @app.call(env)
    end
  end
end

# if Rails.env.production?
#   Rails.application.middleware.insert_before Rails::Rack::Logger, MyLogger::MyMiddleware
# end
