class OrdersChannel < ApplicationCable::Channel
  def subscribed
    stream_from channel
  end

end
