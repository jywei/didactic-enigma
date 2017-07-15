class Api::V1::ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token
  include Devise::Controllers::Helpers
  include User::Authenticator
  include ::ExceptionLogger
  before_action :verify_token
  around_action :rescue_to_log

  def_param_group :user_authentication do
    example '// 使用者未登入
      {
        "code": 3,
        "message": "User not logged in"
      }'
          example '// 於別的地方登入或token過期
      {
        "code": 1,
        "message": "Token Outdated"
      }'
          example '// 錯誤的認證token
      {
        "code": 2,
        "message": "Invalid Token"
      }'
  end
end
