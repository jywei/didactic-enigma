# For user validation in controllers
module User::Authenticator
  def current_user
    return @current_user if @current_user
    user = User.find_by(access_token: parsed_token)
    if user
      Rails.logger.info("User Found from COOKIE: #{user.id}")
      @current_user = user
    else
      Rails.logger.info("User not found with COOKIE: #{parsed_token}")
      nil
    end
  end

  def verify_token
    case
    when no_token?
      render json: { code: 3, message: 'User not logged in' }
    when token_outdated?
      render json: { code: 1, message: 'Token Outdated' }
    when current_user.nil?
      render json: { code: 2, message: 'Invalid Token' }
    else
      Rails.logger.info("current_user is ##{current_user.id} #{current_user.username}")
      true
    end
    false
  end

  def raw_cookie
    request.env["HTTP_COOKIES"] || request.env["HTTP_COOKIE"] || ""
  end

  def parsed_token
    return request.cookies['user'] if Rails.env.test?
    # Rails.logger.info("User COOKIE: #{request.cookies.class}: #{request.cookies}")
    if raw_cookie.index('user=')
      unparsed = raw_cookie.gsub("%24", "$").gsub("%2F", "/").gsub("%22%7D", "")
      # Rails.logger.info("User COOKIE UNPARSED: #{unparsed}")
      parsed = unparsed[unparsed.index("$2a")...unparsed.index("$2a") + 60]
      # Rails.logger.info("User COOKIE PARSED: #{parsed}")
      parsed
    else
      return nil unless request.cookies['user']
      JSON.parse(request.cookies['user'])['token']
    end
  end

  def token_outdated?
    Rails.logger.info("Token: #{parsed_token}")
    User::Token.find_by(content: parsed_token)
  end

  def no_token?
    Rails.logger.info("Cookie: #{raw_cookie}")
    if raw_cookie.to_s.include?('user') || request.cookies['user'].present?
      false
    else
      true
    end
  end
end
