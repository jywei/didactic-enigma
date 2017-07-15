module Operation
  class Order
    include User::QuotaComputer
    # 注單傳入的參數：
    #
    # {
    #   amount: 20000,
    #   prize: 50000,
    #   rate_mode: 'any',
    #   items: [
    #     {
    #       match_id: Match.active.to_a.sample.key,
    #       team: 'h',
    #       offer: 'ml',
    #       odd: 0.96,
    #     },
    #     {
    #       match_id: Match.active.to_a.sample.key,
    #       team: 'h',
    #       offer: 'point',
    #       asia_proportion: 30
    #       odd: 0.96,
    #     }
    #   ]
    # }
    #
    # 回傳值code
    # 0 => 下注成功
    # 1 => 賠率已變動
    # 2 => 注額超過上限
    # 3 => 該玩法不存在
    # 4 => 該玩法已停押
    # 5 => 該玩法已停盤
    # 6 => 該玩法屬於滾球項目，不再提供串關玩法
    # 7 => 傳入欄位不足
    # 9 => 伺服器錯誤

    def initialize(args, current_user = nil, channel = nil, user_channel = nil, client_ip = nil, is_test = false)
      raise 'current_user is not specified in operation.'         if current_user.nil?
      raise 'current_user_channel is not specified in operation.' if channel.nil? && !is_test
      raise 'client_ip is not specified in operation.'            if client_ip.nil?
      @args          = args.with_indifferent_access
      @current_user  = current_user
      @channel       = channel
      @user_channel  = user_channel
      @ip            = client_ip
      @parlay_serial = args[:parlay_serial]
      @serial        = args[:serial]
      @is_test       = is_test
    end

    def place!
      if parlay?
        Parlay.new(@args, @current_user, @channel, @user_channel, @ip, @is_test).place!
      else
        Normal.new(@args, @current_user, @channel, @user_channel, @ip, @is_test).place!
      end
    end

    def create_order(is_valid = true, parlay_serial = nil, parlay_count = nil)
      order = ::Order.new(
        time:          Time.now,
        ip:            @ip,
        amount:        @args[:amount].to_i,
        user:          @current_user,
        type_flag:     order_type(@args[:rate_mode]),
        parlay_serial: parlay_serial,
        parlay_count:  parlay_count,
        is_valid:      is_valid,
        current_quota: @current_user.remaining_quota_today - @args[:amount].to_i
      )
      order.save!
      calculate_current_quota(@current_user)
      order
    end

    def offer_stat(offer)
      stat_code, message = if offer.nil? || offer[:stat] == 'unavailable'
                             [3, 'offer is unavailable']
                           elsif offer[:stat] == 'paused'
                             [4, 'offer is paused']
                           elsif offer[:stat] == 'disabled'
                             [5, 'offer is disabled']
                           else
                             0
                           end
      {
        code:    stat_code,
        message: message
      }
    end

    def odd_in_redis
      @odd_in_redis ||= (target_offer[team].to_f + target_offer["#{team}_modifier"].to_f).round(3)
    end

    def parlay?
      @args[:items].size > 1
    end

    def offer_type(offer)
      offer[:asian_new] ? :asian : :normal
    end

    def order_type(type)
      items = @args[:items][0]
      offer = $redis.afu_match!(items[:match_id])[:parlay][items[:offer]]
      if offer[:is_running]
        :running
      else
        parlay? ? :parlay : :normal
      end
    end

    def user_setting_valid?
      prize = @args[:prize]
      if prize > 1000000 || prize > @current_user.remaining_quota_today
        broadcast_code 2
        return
      end
      true
    end
  end
end
