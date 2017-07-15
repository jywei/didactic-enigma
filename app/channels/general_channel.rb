# 總頻道使用於所有一般用途的事件，目前包含登入登出以及驗證三項
class GeneralChannel < ApplicationCable::Channel
  include ApplicationCable::Authentication
  include User::QuotaComputer

  # 連線的callback，會訂閱兩個stream
  #
  # - "GeneralChannel"
  # - "user_1234567"
  #
  # 除了頻道本身之外，另一個是亂數名稱，每個使用者有自己的一組亂數，作為單獨廣播使用。
  #
  # 訂閱成功以後，就可以使用這兩條stream來傳送訊息給使用者：
  #
  # ```ruby
  # ActionCable.server.broadcast("GeneralChannel", foo: "bar")
  # ActionCable.server.broadcast(user_channel, foo: "bar")
  # ```
  def subscribed
    stream_from channel
    stream_from user_channel
  end

  # 登入行為，帳號密碼明碼傳遞，厲害吧！
  #
  # 參數：
  #
  # ```ruby
  # {
  #   username: String,
  #   password: String
  # }
  # ```
  #
  # 若登入成功回傳：

  # ```ruby
  # {
  #   code: 1,
  #   token: "12334445657"
  # }
  # ```

  # 該token是用於在update_status這個action當中取得使用者資料用。

  # 登入失敗則回傳：

  # ```ruby
  # {
  #   code: 0,
  #   message: "智商太低不能登入"
  # }
  # ```
  def sign_in(args)
    sleep 0.5
    args = args.with_indifferent_access
    @response = Response.new('sign_in')

    if args[:username].blank? && args[:password].blank?
      @response.validated
      @response.message = '帳號或密碼不可空白'
      send_to_user @response.to_render
      return
    end

    user = User.find_by(username: args[:username], encrypted_password: args[:password])
    if user.nil?
      @response.incorrected
      @response.message = '找不到使用者或密碼'
      send_to_user @response.to_render
      return
    end

    connection.connection_user = user
    user.refresh_token
    @response.succeed
    @response.message = "登入成功"
    @response.set_column :token, user.access_token
    calculate_current_quota(current_user) unless user.is_admin
    send_to_user @response.to_render
  rescue => e
    logging_error(args, __method__, e)
    raise e
  end

  # 登出，不傳送任何參數，會將目前連線的使用者移除，但僅限於server端的調整，
  # 瀏覽器端自己要將cookie移除。
  def sign_out
    Rails.logger.info("sign_out user is #{current_user.try(:id)}. #{current_user.try(:username)}")
    User::Token.create(content: current_user.try(:access_token), user_id: current_user.try(:id), reason: "user has signed out")
    current_user.update(access_token: 'user has signed out')
    send_to_user code: 1, action: 'sign_out', message: "ok"
    connection.connection_user = nil
  rescue => e
    logging_error({}, __method__, e)
    raise e
  end

  # 狀態更新，這時候會呼叫 User::TokenValidator 來驗證該組
  # token是否過期，若過期，則回傳過期訊息，未過期就回傳使用者資訊。
  #
  # 參數：
  #
  # ```ruby
  # {
  #   token: "123456778"
  # }
  # ```
  #
  # 回傳值相同於 User::TokenValidator#validate
  #
  def update_status(args)
    result = User::TokenValidator.new(args['token'], args['pass']).validate
    send_to_user result
  end
end
