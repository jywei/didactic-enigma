module Operation
  class Order
    class Parlay < ::Operation::Order
      include Operation::Order::Broadcast

      def place!
        if parlay_combination?
          combination_place!
        else
          parlay_place!
        end
      end

      def combination_place!
        if offers_available?
          create_parlay_order(true)
          broadcast_success_message
        else
          create_order(false, parlay_serial, parlay_count)
        end
        validate_combination
      end

      def parlay_place!
        return unless offers_available?
        return unless user_setting_valid?
        create_parlay_order
        broadcast_success_message
      end

      def offers_available?
        @args[:items].each do |item|
          stat = offer_stat($redis.afu_match!(item[:match_id])[:parlay][item[:offer]])
          if stat[:code] != 0
            broadcast_code stat[:code], message: stat[:message]
            return false
          end
        end
        true
      end

      def create_parlay_order(is_valid = true)
        ::Order.transaction do
          @order = create_order(is_valid, parlay_serial, parlay_count)
          @order.create_items_with(@args[:items], "parlay")
          @order.create_items_profile
        end
      end

      def broadcast_success_message
        broadcast_code 0, message: 'ok'
        broadcast_realtime_order(@order)
      end

      def validate_combination
        orders = ::Order.where(parlay_serial: parlay_serial)
        if orders.count == parlay_count && orders.all? { |order| order.is_valid }.!
          orders.destroy_all
        end
      end

      def parlay_combination?
        parlay_serial.present?
      end

      def parlay_serial
        @args[:parlay_serial]
      end

      def parlay_count
        @args[:parlay_count]
      end

    end
  end
end
