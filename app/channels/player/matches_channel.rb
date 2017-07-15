class Player::MatchesChannel < ApplicationCable::Channel
  include ApplicationCable::Subscription
  include ApplicationCable::Authentication

  def subscribed
    super
    stream_from player_channel
  end

  def order(args)
    return unless user_identified_by? cookie_from args
    return unless sufficient args
    remote_ip = connection.env['action_dispatch.remote_ip']
    client_ip = remote_ip ? remote_ip.calculate_ip : "unknown"
    Operation::Order.new(args, current_user, player_channel, user_channel, client_ip).place!
  rescue => e
    send_to_player code: 9, action: 'order', message: 'internal server error', serial: args['serial']
    logging_error(args, __method__, e)
    raise e
  end

  def sufficient(args)
    %w(rate_mode amount prize items).all? do |key|
      if args[key].blank?
        send_to_player(code: 7, action: 'order', message: "Insufficient arguments: getting null or blank data from key '#{key}'")
        false
      else
        true
      end
    end
  end
end
