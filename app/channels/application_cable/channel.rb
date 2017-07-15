module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def channel
      self.class.name
    end

    def set_args(args)
      @args = args
    end

    def broadcast(message)
      ActionCable.server.broadcast channel, message
    end

    def connect_id
      connection.connection_identifier
    end

    def user_channel
      # "user_#{connect_id}"
      connection.user_channel
    end

    def player_channel
      "player_#{connect_id}"
    end

    def index_channel
      "index_#{connect_id}"
    end

    def send_to_user(message)
      ActionCable.server.broadcast user_channel, message
    end

    def send_to_player(message)
      ActionCable.server.broadcast player_channel, message
    end

    def current_user
      connection.connection_user.class_to_admin
    end

    def current_user=(obj)
      connection.connection_user = obj
    end

    def logging_error(args, action, e, uuid = nil)
      user_id = current_user.try(:id)
      Log::Error.create!(
        name:      e.class.name,
        user_id:   user_id,
        path:      "#{channel}##{action}",
        uuid:      uuid,
        message:   e.message,
        params:    args,
        backtrace: e.backtrace,
        data:      []
      )
    end

    alias_method :current_connection, :connection
  end
end
