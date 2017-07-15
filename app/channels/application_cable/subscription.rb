module ApplicationCable
  module Subscription
    def subscribed
      stream_from channel
    end

    # def subscribed
    #   stream_from channel
    #
    #   connection_identifier  = connection.object_id
    #   authentication_channel = "#{channel}_#{connection_identifier}"
    #   stream_from authentication_channel
    #
    #   sleep 0.5
      # ActionCable.server.broadcast authentication_channel, action: 'authentication', channel: authentication_channel
    # end

    # def unsubscribed
    # end
  end
end
