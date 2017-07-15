module Operation
  class Order
    module Broadcast
      def broadcast_code(code, args = {})
        data = {
          action: 'order',
          serial: @serial,
          code: code
        }
        data[:parlay_serial] = @parlay_serial if @parlay_serial
        args[:data] = {}
        args[:data][:updated_odd] = odd_in_redis if code == 1
        data.merge!(args)
        ActionCable.server.broadcast(@channel, data)
      end

      def broadcast_realtime_order(order)
        data = order.history
        ActionCable.server.broadcast("OrdersChannel", data)
      end

      def update_position_and_broadcast
        # match.add_stake!(@args)
        target_match.adjust_position_from_orders!(normal_order_args)
        broadcast_code 0, message: 'ok'
        ActionCable.server.broadcast(@user_channel, { action: 'current_quota', current_quota: @current_user.remaining_quota_today })
        @offer = target_offer
        @offer.update_position_to_log_from(normal_order_args.merge(order_id: @order.id))
        ActionCable.server.broadcast("PositionsChannel", target_match.position_update(normal_order_args))
        ActionCable.server.broadcast("MatchesChannel", target_match.stake_and_positions(normal_order_args[:offer]))
        # ActionCable.server.broadcast("player_matches_#{@current_user.id}", @match.reload.stakes(@args[:offer]))
      end

      def normal_order_args(args = nil)
        args ||= @args
        @position_args ||=
          args.merge(
            match_id: args[:items].first[:match_id],
            team:     args[:items].first[:team],
            offer:    args[:items].first[:offer],
            odd:      args[:items].first[:odd]
          )
        @position_args.delete("items")
        @position_args
      end

    end
  end
end
