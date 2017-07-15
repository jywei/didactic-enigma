require 'securerandom'

# 不用我多說，就是Application系列的常數
module ApplicationCable
  # 使用者建立連線之後，會產生一個Connection物件存在ActionCable的連線管理當中，
  # 一般取得方式是在使用者執行WebSocket行為時，從Channel內取得。
  #
  # 例如使用者利用登入時，我們要設定這條連線的使用者：
  #
  # ```ruby
  # class GeneralChannel < ApplicationCable::Channel
  #   def sign_in(args)
  #     user = User.find_by(username: args["username"], password: args["password"])
  #     if user
  #       connection.connection_user = user
  #     end
  #   end
  # end
  # ```
  #
  # 這只是示範，驗證方式很爛，小朋友不要學。
  #
  class Connection < ActionCable::Connection::Base
    include User::Authenticator
    include Authentication
    identified_by :client_identifier, :connection_user

    # 設定這條連線使用token已經過期
    attr_accessor :token_outdated

    # 使用者建立連線以後會執行的callback，通常用於使用者驗證
    def connect
      self.client_identifier = SecureRandom.hex(5)
      self.connection_user = find_current_user
    end

    # 使用者訂閱的頻道名稱，通常用於廣播給特定使用者使用
    #
    # ```ruby
    # ActionCable.server.broadcast(user_channel, msg: "You're my bitch.")
    # ```
    def user_channel
      "user_#{client_identifier}"
    end

    # 利用瀏覽器cookie找到使用者，找到就設定，找不到就不設定(廢話)
    def find_current_user
      Rails.logger.info("C Validating token")
      if no_token?
        Rails.logger.info("C Token not found")
        nil
      elsif u = token_outdated?
        Rails.logger.info("C Token found in User::Token as ##{u.id}")
        @token_outdated = true
        nil
      else
        unless parsed_token
          Rails.logger.info("C Invalid token ##{parsed_token}")
          nil
        end
        user = User.find_by(access_token: parsed_token)
        if user
          Rails.logger.info("C User found as ##{user.id} #{user.username}")
          user
        else
          Rails.logger.info("C User not found with token #{parsed_token}")
          nil
        end
      end
    end
  end
end
