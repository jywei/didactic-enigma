require 'colorize'

# 控盤人員連線頻道，用於調整盤表，行為主要包含調整賠率，球頭，以及狀態的action。
# 而透過這個頻道也會收到賠率更新，球頭調整，狀態調整等事件。
class MatchesChannel < ApplicationCable::Channel
  include ApplicationCable::Authentication

  # 在訂閱時檢查使用者是不是控盤人員，如果不是，就不會訂閱到控盤的stream上。
  #
  # 如果訂閱成功，則可以透過廣播來聯絡該使用者：
  #
  # ```ruby
  # ActionCable.server.broadcast("MatchesChannel", foo: "bar")
  # ```
  def subscribed
    if current_user.is_admin?
      stream_from channel
    end
  end

  # 調整賠率使用的action
  #
  # 參數：
  #
  # ```ruby
  # {
  #   match_id: String,
  #   offer: String,
  #   type: String, # => 隊伍 'h', 'a', or 'asian'
  #   modifier: Float,
  #   last_updated: Integer,
  #   cookie: String,
  #   offer_type: String, # => 'normal', 'parlay', or 'asian'
  # }
  # ```
  #
  # 流程上剛開始會透過 ApplicationCable::Authentication#user_identified_by? 來驗證使用者是否
  # 登入，但限制不算太嚴格，只要有登入就通過，所以目前就算玩家也可以進行調盤，棒棒！
  #
  # 接下來會將比賽利用 Cache::Lock::Match 在redis當中鎖起來，確保沒有其他人正在調同一場比賽，
  # 並檢查目標要調整的玩法是否有開盤，沒開盤就不處理。
  #
  # 確認都完成之後，便透過 Match::Open#update_odd! 將賠率調整至目標賠率，最後廣播回給控盤人員
  # 及玩家。
  #
  def odd_adjust(args)
    return unless user_identified_by? cookie_from args
    Cache::Lock::Match.lock(args['match_id']) do
      @match = $redis.afu_match!(args['match_id'])
      if args["offer"] != 'all' && @match[:play][args["offer"]].available?.!
        send_to_user action: 'odd', code: 1, message: 'offer not available'
        return
      end
      # 如果要調整的目標比賽不存在就當作沒這回事
      return unless @match
      args['user_id'] = current_user.id
      @match.update_odd!(args)

      # 將調盤的結果廣播送給控盤人員
      ActionCable.server.broadcast(
        'MatchesChannel',
        # @match.offer_odd_modifier(args)
        @match.admin_offer_odd(
          args['offer'],
          args['type'],
          args['last_updated']
        )
      )
      # 將調盤的結果廣播送給玩家
      ActionCable.server.broadcast(
        'Player::MatchesChannel',
        # @match.offer_odd(
        @match.player_offer_odd(
          args['offer'],
          args['type'],
          args['last_updated']
        )
      )
    end
  rescue => e
    logging_error(args, __method__, e)
    raise e
  end

  def stat_change(args)
    return unless user_identified_by? cookie_from args
    @match = $redis.afu_match!(args['match_id'])
    if args["offer"] != 'all' && @match[:play][args["offer"]].available?.!
      send_to_user action: 'odd', code: 1, message: 'offer not available'
      return
    end
    if @match
      @match.change_stat!(args)
      ActionCable.server.broadcast(
        'MatchesChannel',
        @match.offer_stat(
          args,
          current_user
        )
      )
      ActionCable.server.broadcast(
        'Player::MatchesChannel',
        @match.offer_stat(args)
      )
    end
  rescue => e
    logging_error(args, __method__, e)
    raise e
  end

  # fake API
  def stake_update(args)
    @match = $redis.afu_match!(args['match_id'])
    if @match
      ActionCable.server.broadcast(
        'MatchesChannel',
        @match.stakes(args['offer'])
      )
    end
  rescue => e
    logging_error(args, __method__, e)
    raise e
  end


  def match_live(args)
    @match = $redis.afu_match!(args['match_id'])
    @match[:is_running] = args['is_running']
    @match.send(args['offer'].to_sym)[:is_running] = args['is_running'];
    @match.save!
    ActionCable.server.broadcast(
      'MatchesChannel',
      action:     'match_live',
      match_id:   args["match_id"],
      is_running: args["is_running"]
    )
    ActionCable.server.broadcast(
      'Player::MatchesChannel',
      action:     'match_live',
      match_id:   args["match_id"],
      is_running: args["is_running"]
    )
  end

  # fake API
  def random_head(args)
    @match = $redis.afu_match!(args['match_id'])
    if @match
      ActionCable.server.broadcast(
        'MatchesChannel',
        @match.new_head(args['offer'],
                        h: %w(0.1 0.2 0.3 0.4 0.5).sample.to_f.round(1),
                        a: %w(0.1 0.2 0.3 0.4 0.5).sample.to_f.round(1),
                        d: %w(0.1 0.2 0.3 0.4 0.5).sample.to_f.round(1),
                        head: %w(1 2 3 4 5 6 7 8 9).sample.to_i,
                        proportion: %w(10 20 30 40 50 60).sample.to_i
                       )
      )
    end
  end
end
