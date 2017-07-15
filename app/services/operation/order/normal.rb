module Operation
  class Order
    class Normal < ::Operation::Order
      include Operation::Order::Broadcast
      # class << self

        def team_is(name)
          Match.find(target_match['id']).hteam.name == name
        end

        def place!
          return unless offer_available?
          # === 假的隊名，提供前端測試用API ===
          case
          when team_is('odd up')
            puts "odd up"
            target_offer[team] = target_offer[team] + 0.01
            target_match.save!
          when team_is('odd down')
            puts "odd down"
            target_offer[team] = target_offer[team] - 0.01
            target_match.save!
          when team_is('注額超過上限')
            broadcast_code 2
            return
          when team_is('不存在的玩法，跟不存在的房間一樣')
            broadcast_code 3
            return
          when team_is('玩法停押')
            broadcast_code 4
            return
          when team_is('玩法停盤')
            broadcast_code 5
            return
          when team_is('伺服器錯誤')
            broadcast_code 9
            return
          end
          # ================================

          if not Rails.env.test?
            puts "Incoming odd: #{odd.to_f.round(3)}"
            puts "Odd in redis: #{odd_in_redis}"
            puts "worse: #{worse_odd?}"
            puts "different: #{different_odd?}"
          end

          case @args[:rate_mode]
          when 'any'
            # It passes with any odd change
          when 'best'
            if worse_odd?
              broadcast_code 1
              return
            end
          when 'normal'
            if different_odd?
              broadcast_code 1
              return
            end
          end

          ::Order.transaction do
            @order = create_order
            @order.create_items_with(@args[:items], "play")
            @order.create_items_profile
          end

          # 如果是test模式跳過廣播
          if @is_test == false
            update_position_and_broadcast
            broadcast_realtime_order(@order)
          end
        end

        def odd
          @args[:items][0][:odd]
        end

        def worse_odd?
          odd.to_f.round(3) < odd_in_redis
        end

        def different_odd?
          odd.to_f.round(3) != odd_in_redis
        end

        def offer_available?
          stat = offer_stat(target_offer)
          if stat[:code] != 0
            broadcast_code stat[:code], message: stat[:message]
            false
          else
            true
          end
        end

        def target_match
          @match ||= $redis.afu_match!(item[:match_id])
        end

        def target_offer
          @offer ||= target_match[:play][item[:offer]]
        end

        def item
          @args[:items][0]
        end

        def team
          item[:team]
        end

      # end
    end
  end
end
