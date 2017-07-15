module ApplicationCable
  module Authentication

    def user_identified_by?(cookie)
      Rails.logger.info("WebSocket is authenticating with cookie: #{cookie}")
      if cookie.blank?
        send_to_user action: 'authenticated', code: 3, msg: 'Cookie not found'
        return false
      end

      if User::Token.find_by(content: cookie)
        send_to_user action: 'authenticated', code: 1, msg: 'Token outdated'
        connection.connection_user = nil
        return false
      end

      if connection.connection_user
        true
      else
        user = User.find_by(access_token: cookie)
        if user
          connection.connection_user = user
          true
        else
          send_to_user action: 'authenticated', code: 2, msg: 'User not found'
          false
        end
      end
    end

    def cookie_from(args)
      if args['cookie']
        # 後台假資料區專用
        if args['cookie'].is_a? String
          JSON.parse(args['cookie'])
        # 正常情況
        else
          args['cookie']['token']
        end
      end
    end

  end
end
