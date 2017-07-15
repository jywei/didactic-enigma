# 驗證使用者token是否過期
class User::TokenValidator
  # 產生新的instance時需要帶入兩個參數：
  #
  # - token: String 拿來驗證的token，例如"1234567889"
  # - force: TrueClass 或 FalseClass 測試用的參數，如果有帶值例如true，就一定會通過驗證，如果是false就一定不會通過
  #
  def initialize(token, force = nil)
    @response = Response.new('update_status')
    @token    = token
    @force    = force
  end

  # 驗證token是否過期，會有幾個步驟：
  #
  # - 如果在 User::Token 這張table當中找到token，代表已經由其他
  # 瀏覽器登入過，此筆token就算過期。
  # - 如果force這個參數有帶入true，就一定會通過驗證
  # - 如果user登入已經超過一天，則就算沒有通過
  #
  # 驗證成功則回傳：
  #
  # ```ruby
  # {
  #   code: 1,
  #   message: "ok",
  #   user: {
  #     id: 1,
  #     name: "foo",
  #     identity: "bar",
  #     tier: 1,
  #     token: "123456778",
  #     quota: "100000"
  #   }
  # }
  # ```
  #
  # 驗證失敗則回傳：
  #
  # ```ruby
  # {
  #   code: 0,
  #   message: "token outdated"
  # }
  # ```
  def validate
    token = User::Token.find_by(content: @token)

    if token
      @response.failed
      @response.message = 'token outdated'
      return @response.to_render
    end

    user = User.find_by_access_token(@token)
    user = user.class_to_admin # => 如果找到的User是Admin自動轉型。
    if @force == true
      @response.succeed
      @response.message = 'ok'
      @response.set_column :user, user.info
      return @response.to_render
    elsif @force == false
      @response.failed
      @response.message = 'token outdated'
      return @response.to_render
    end

    if user.updated_at < Time.now.yesterday
      @response.failed
      @response.message = 'token outdated'
      return @response.to_render
    else
      @response.succeed
      @response.message = 'ok'
      @response.set_column :user, user.info
      return @response.to_render
    end
  end
end
