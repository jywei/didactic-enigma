class ApplicationController < ActionController::Base
  include User::Authenticator
  include ExceptionLogger
  protect_from_forgery with: :exception
  helper_method :current_user
  # around_action :rescue_to_log

  def current_user
    return @current_user if @current_user
    return nil if no_token?
    user = User.find_by(access_token: parsed_token)
    if user
      @current_user = user
    else
      Rails.logger.info("User not found with token #{parsed_token}")
      nil
    end
  end
end
