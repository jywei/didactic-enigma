# 所有廣播API都會同時存在三個欄位：
#
# 1. _match_id         給遊戲端使用的比賽ID
# 2. _halves_match_id  尚未使用
# 3. match_id          給遊戲端(存match底下在第二層halves_match)和控端使用的比賽ID
#
# 這三個看起來有點混淆的欄位，在遙遠的未來，會改成：
# match_id        同時給控端和遊戲端使用的比賽ID
# halves_match_id 同時給控端和遊戲端使用的第二層比賽ID
#
# 資料結構可參考Match::Open.query_by(action: :group)撈出來的資料
module Match::Open::Serializer
  # 控盤端更新賠率調整值-手動調賠率廣播到控端
  def admin_offer_odd(offer_name, team, timestamp)
    # base     = odd_base_from(offer_name, team)
    # modifier = odd_modifier_from(offer_name, team)
    # result   = (base + modifier).round(3)
    {
      _match_id:        self[:_match_id],
      _halves_match_id: self[:_halves_match_id],
      match_id:         self[:match_id],
      offer:            offer_name,
      team:             team,
      # odd:             result,
      # modifier:     modifier, # will be replaced
      modifier:         odd_modifier_from(offer_name, team),
      parlay_modifier:  parlay_modifier_from(offer_name, team),
      index:            Info::OddType.indexes[offer_name],
      last_updated:     timestamp,
      action:           'odd_manual_change'
    }
  end

  # 遊戲端更新最終賠率-手動調賠率廣播到遊戲端
  def player_offer_odd(offer_name, team, timestamp)
    base     = odd_base_from(offer_name, team)
    modifier = odd_modifier_from(offer_name, team)
    result   = (base + modifier).round(3)

    parlay_base     = parlay_odd_base_from(offer_name, team)
    parlay_modifier = parlay_modifier_from(offer_name, team)
    parlay_result   = (parlay_base + parlay_modifier).round(3)
    odd_change = {
      _match_id:        self[:_match_id],
      _halves_match_id: self[:_halves_match_id],
      match_id:         self[:match_id],
      offer:            offer_name,
      team:             team,
      # modifier:     modifier, # will be replaced
      #modifier:         odd_modifier_from(offer_name, team),
      #parlay_modifier:  parlay_modifier_form(offer_name, team),
      index:            Info::OddType.indexes[offer_name],
      last_updated:     timestamp,
      # 原本的 action:   'odd'
      action:           'odd_manual_change'
    }
    if team == 'asian'
      odd_change[:proportion] = result
      odd_change[:parlay_proportion] = parlay_result
    else
      odd_change[:odd] = result
      odd_change[:parlay_odd] = parlay_result
    end
    odd_change
  end

  # tx自動調賠率廣播到遊戲端
  def gamer_leader_offer_odd(offer_name, timestamp)
    offer  = self[:play][offer_name.to_sym]
    parlay = self[:parlay][offer_name.to_sym]
    odds   = {
      _match_id:        self[:_match_id],
      _halves_match_id: self[:_halves_match_id],
      match_id:         self[:match_id],
      offer:            offer_name,
      # action:         'odd_base'
      action:           'odd_auto_change',
      h:                offer[:h] + offer[:h_modifier].to_f.round(3),
      a:                offer[:a] + offer[:a_modifier].to_f.round(3),
      parlay_h:         parlay[:h] + parlay[:h_modifier].to_f.round(3),
      parlay_a:         parlay[:a] + parlay[:a_modifier].to_f.round(3),
      last_updated:     timestamp
    }
    odds[:d]        = offer[:d]  + offer[:d_modifier].to_f.round(3) if offer[:d]
    odds[:parlay_d] = parlay[:d] + parlay[:d_modifier].to_f.round(3) if parlay[:d]
    odds
  end

  # 控盤端更新賠率基礎值-tx自動調賠率廣播到控端
  def leader_offer_odds(name)
    #TODO: 部位表資訊，利用基礎值更新來計算出新的部位
    # play   = afu_match[:play]
    # parlay = afu_match[:parlay]
    play   = self[:play][name]
    parlay = self[:parlay][name]
    {
      _match_id:        self[:_match_id],
      _halves_match_id: self[:_halves_match_id],
      match_id:         self[:match_id],
      offer:            name,
      h_base:           play[:h],
      a_base:           play[:a],
      d_base:           play[:d],
      parlay_h_base:    parlay[:h],
      parlay_a_base:    parlay[:a],
      parlay_d_base:    parlay[:d],
      # modifier: modifier, # will be replaced
      # index:    Info::OddType.indexes[name],
      last_updated:     DateTime.mil,
      action:           'odd_auto_change'
    }
  end

  def offer_stat(args, user = nil)
    # args['offer'], args['stat']
    args = args.with_indifferent_access
    args[:user_id] = user.id if user
    args.merge(
      _match_id:        self[:_match_id],
      _halves_match_id: self[:_halves_match_id],
      match_id:         self[:match_id],
      index:            Info::OddType.indexes[args['offer']],
      action:           'stat'
    )
  end

  def stakes(offer_name = 'three_way')
    offer_name = offer_name.to_sym
    offer      = send(offer_name.to_sym)
    stake_hash = {
      _match_id:        self[:_match_id],
      _halves_match_id: self[:_halves_match_id],
      match_id:         self[:match_id],
      match_h_stake:    self[:h_stake],
      match_a_stake:    self[:a_stake],
      offer:            offer_name.to_s,
      offer_h_stake:    offer[:h_stake],
      offer_a_stake:    offer[:a_stake],
      action:           'stake'
    }
    stake_hash[:match_d_stake] = self[:d_stake] if self[:play].keys.include?('three_way')
    stake_hash[:offer_d_stake] = offer[:d_stake] if offer_name == :three_way
    stake_hash
  end

  # tx更新球投的時候的廣播資料
  def new_head(offer_name, args = {}, channel)
    # args is for testing random value
    offer  = send(offer_name.to_sym)
    parlay = parlays[offer_name]
    hash = {
      action:           'update_head',
      _match_id:        self[:_match_id],
      _halves_match_id: self[:_halves_match_id],
      match_id:         self[:match_id],
      offer:            offer_name,
      h:                args[:h] || (offer[:h] + offer[:h_modifier].to_f).round(3),
      a:                args[:a] || (offer[:a] + offer[:a_modifier].to_f).round(3),
      parlay_h:         (parlay[:h] + parlay[:h_modifier].to_f).round(3),
      parlay_a:         (parlay[:a] + parlay[:a_modifier].to_f).round(3),
      stat:             'normal',
      handicapped: {
        head:           args[:head] || offer[:handicapped][:head]
     }
    }
    if channel == 'MatchesChannel'
      hash[:handicapped][:proportion] = args[:proportion] || offer[:handicapped][:proportion]
      hash[:handicapped][:modifier] = offer[:handicapped][:modifier]
    elsif channel == 'Player::MatchesChannel'
      hash[:handicapped][:proportion] = (args[:proportion] || offer[:handicapped][:proportion]) + offer[:handicapped][:modifier]
    else
      puts '使用Serializer的new_head 沒有指定格式'
    end

    if offer_name == 'three_way'
      hash[:d]        = args[:d] || (offer[:d] + offer[:d_modifier])
      hash[:parlay_d] = parlay[:d] + parlay[:d_modifier]
    end
    hash
  end

  def broadcast_scores
    {
      h_score:      self[:h_score],
      a_score:      self[:a_score],
      match_result: self[:match_result]
    }
  end

  def broadcast_new_offer(offer_name)
    offer = self[:play][offer_name.to_sym]
    ActionCable.server.broadcast('MatchesChannel',         leader_offer_odds(offer_name, offer[:h], offer[:a], offer[:d]))
    ActionCable.server.broadcast('Player::MatchesChannel', gamer_leader_offer_odd(offer_name, DateTime.mil))
    stat = {
      action:           'stat',
      _match_id:        self[:_match_id],
      _halves_match_id: self[:_halves_match_id],
      match_id:         self[:match_id],
      offer:            offer_name,
      stat:             'normal'
    }
    ActionCable.server.broadcast('MatchesChannel',         stat)
    ActionCable.server.broadcast('Player::MatchesChannel', stat)
  end

  def broadcast_new_match
    ActionCable.server.broadcast(
      'MatchesChannel',
      action: 'new_match',
      match:  self
    )
    ActionCable.server.broadcast(
      'Player::MatchesChannel',
      action: 'new_match',
      match:  to_gamer
    )
  end

  def to_gamer
    gamer = clone
    gamer.delete(:h_stake)
    gamer.delete(:a_stake)
    gamer.delete(:d_stake)
    gamer[:play].each do |_, offer|
      %i(h_modifier a_modifier d_modifier h_stake a_stake d_stake water).each do |attr|
        offer.delete(attr)
      end
      offer[:handicapped].delete(:modifier)
    end
    gamer
  end

  def to_position
    attributes  = keep(*%w(_match_id _halves_match_id match_id match_number team h_stake a_stake d_stake halves))
    offer_attrs = %w(stat type type_ch index h_stake a_stake d_stake positions thresholds distances)
    attributes[:play] = self[:play].each_with_object({}) do |offer_pair, result|
      result[offer_pair[0]] = offer_pair[1].keep(*offer_attrs)
    end
    attributes
  end

  # 廣播至控端部位表的部位更新
  def position_update(position_changes)
    offer = self.reload[:play][position_changes[:offer]]
    position_hash = {
                      action:           'positions',
                      match_id:         self[:match_id],
                      _match_id:        self[:_match_id],
                      _halves_match_id: self[:_halves_match_id],
                      offer:            position_changes[:offer],
                      positions:        offer[:positions],
                      thresholds:       offer[:thresholds],
                      distances:        offer[:distances]
                    }
    warning_trigger(offer) ? create_warning(position_hash) : position_hash
  end

  # 廣播至控端控盤的賭金及部位更新
  def stake_and_positions(offer_name)
    offer = self[:play][offer_name.to_sym]
    {
      action:           'stake_and_positions',
      _match_id:        self[:_match_id],
      _halves_match_id: self[:_halves_match_id],
      match_id:         self[:match_id],
      match_stakes: {
                        h: self[:h_stake],
                        a: self[:a_stake]
                    }.merge(self[:d_stake] ? { d: self[:d_stake] } : {}),
      offer: offer_name,
      offer_stakes: {
                        h: offer[:h_stake],
                        a: offer[:a_stake]
                    }.merge(offer[:d_stake] ? { d: offer[:d_stake] } : {}),
      positions:        offer[:positions],
      thresholds:       offer[:thresholds],
      distances:        offer[:distances]
    }
  end

  protected

  def warning_trigger(offer)
    offer[:distances].select { |_, value| value >= 100.0 }.any?
  end

  def create_warning(hash)
    hash[:action] = "position_warning_alert"
    hash
  end

  def odd_base_from(offer, team)
    o = send(offer.to_sym)
    team == 'asian' ? o[:handicapped][:proportion] : o[team.to_sym]
  end

  def odd_modifier_from(offer, team)
    o = send(offer.to_sym)
    team == 'asian' ? o[:handicapped][:modifier] : o["#{team}_modifier"]
  end

  def parlay_odd_base_from(offer, team)
    o = send("parlay_#{offer}".to_sym)
    team == 'asian' ? o[:handicapped][:proportion] : o[team.to_sym]
  end

  def parlay_modifier_from(offer, team)
    o = send("parlay_#{offer}".to_sym)
    team == 'asian' ? o[:handicapped][:modifier] : o["#{team}_modifier"]
  end
end
