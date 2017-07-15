# 儲存於redis內的offer，資料結構會歸屬在 Match::Open 和 Offer::Open::Collection 之下
class Offer::Open < ActiveSupport::HashWithIndifferentAccess
  include Operation::Odd::Algorithm

  delegate :offers, to: :match

  def initialize(args = {}, match_key)
    args.each { |k, _| self[k] = args[k] }
    @match_key = match_key
  end

  # 找到自己在db內的 Offer
  def db_offer
    case
    when self[:is_parlay]
      Offer::Parlay.find(self[:parlay_id])
    when self[:asian_new]
      Offer::Asian.find(self[:asian_id])
    else
      Offer.find(self[:offer_id])
    end
  end

  # 找到自己是屬於哪一場 Match::Open
  def match
    $redis.afu_match!(@match_key)
  end

  # 看目前這個玩法總賭金為何
  def stake
    self[:h_stake] + self[:a_stake] + self[:d_stake]
  end

  # 根據門檻的移動來調整特定玩法的部位
  #
  # 參數同 Match::Open#adjust_position_from_orders!
  #
  def update_from_thresholds(args)
    update_thresholds(args)
    update_distances
  end

  # 根據注單來調整特定玩法的部位
  #
  # 參數同 Match::Open#adjust_position_from_orders!
  #
  def update_from_order(args)
    update_stake(args)
    update_wager(args)
    update_positions(args)
    update_distances
  end

  # 將資料庫的 Offer 更新到自己身上
  #
  # 參數：
  #
  # ```ruby
  # {
  #   is_running: Boolean,
  #   last_updated: String,
  #   stat_changed: Boolean
  # }
  # ```
  def sync(options = {})
    offer = db_offer
    if db_offer.asian?
      self[:handicapped] = {
        head: offer.asian_head.to_i,
        proportion: offer.asian_proportion.to_i,
        modifier: self[:handicapped][:modifier]
      }
    end
    self[:h] = offer.h_odd.to_f.round(3)
    self[:a] = offer.a_odd.to_f.round(3)
    self[:d] = offer.d_odd.to_f.round(3) if offer.try(:d_odd)
    self[:last_updated][:push] = options[:last_updated]
    self[:stat] = offer.stat
  end

  def update_stake(args)
    self["#{args[:team]}_stake"] += args[:amount].to_i
  end

  def update_thresholds(args)
    thresholds = self[:thresholds].keys.each_with_object({}) do |team, result|
      team_threshold      = args[:team] == team ? args[:threshold] : self[:thresholds][team.to_sym]
      result[team.to_sym] = team_threshold.round(1)
    end
    self[:thresholds] = thresholds
  end

  def update_wager(args)
    wagers = self[:wager].keys.each_with_object({}) do |team, result|
      team_wager = args[:team] == team ? (self[:wager][team.to_sym] + args[:prize] + args[:amount]) : self[:wager][team.to_sym]
      result[team.to_sym] = team_wager.round(1)
    end
    self[:wager] = wagers
  end

  def update_positions(args)
    # self[:positions] = evaluate { args[:team] == team ? stake - self[:wager][team.to_sym] : self[:positions][team.to_sym] + args[:amount] }
    positions = self[:positions].keys.each_with_object({}) do |team, result|
      team_position = args[:team] == team ? (stake - self[:wager][team.to_sym]) : (self[:positions][team.to_sym] + args[:amount])
      result[team.to_sym] = team_position.round(1)
    end
    self[:positions] = positions
  end

  def update_distances
    self[:distances] = ::Offer::Position.position_meter(
      current_positions: self[:positions],
      thresholds:        self[:thresholds]
    )
  end

  def update_position_to_log_from(args)
    @match_id = Match.find_by(redis_id: args[:match_id]).id
    Log::Position.create!(
      order_id:          args[:order_id] || nil,
      user_id:           args[:user_id]  || nil,
      offer_position_id: Offer::Position.find_by(match_id: @match_id, offer_name: args[:offer]).try(:id),
      h_position:        self[:positions][:h],
      a_position:        self[:positions][:a],
      d_position:        self[:positions][:d] || nil,
      h_threshold:       self[:thresholds][:h],
      a_threshold:       self[:thresholds][:a],
      d_threshold:       self[:thresholds][:d] || nil,
      h_distance:        self[:distances][:h],
      a_distance:        self[:distances][:a],
      d_distance:        self[:distances][:d] || nil
    )
    create_warning_log(args) if trigger_warning
  end

  def create_warning_log(args)
    sql          = "INSERT INTO `log_position_warnings` (match_id, offer_position_id, warning_level, sport_id, sport_name, category_id, category_name, h_team, a_team, h_team_id, a_team_id, match_time, h_position, a_position, d_position, h_threshold, a_threshold, d_threshold, h_distance, a_distance, d_distance, created_at, updated_at) VALUES "
    time         = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
    match        = Match.find(@match_id)
    match_time   = match.start_time.utc.strftime("%Y-%m-%d %H:%M:%S")
    category     = Category.find(match.category_id)
    sport        = Sport.find_by(leader_spid: category.spid)
    h_team       = Team.find(match.hteam_id).try(:name)
    a_team       = Team.find(match.ateam_id).try(:name)
    position_log = Log::Position.last
    warning_level
    values       = "(#{@match_id}, #{position_log.id}, '#{@warning_level}', #{sport.id}, '#{sport.name}', #{category.id}, '#{category.name}', '#{h_team}', '#{a_team}', #{match.hteam_id}, #{match.ateam_id}, '#{match_time}', #{position_log.h_position}, #{position_log.a_position}, #{position_log.d_position}, #{position_log.h_threshold}, #{position_log.a_threshold}, #{position_log.d_threshold}, #{position_log.h_distance}, #{position_log.a_distance}, #{position_log.d_distance}, '#{time}', '#{time}')"
    ActiveRecord::Base.connection.execute("#{sql}#{values.gsub(', ,', ', NULL,')}")
  end

  def trigger_warning
    @first_warning = 50.0
    @current_distances = [self[:distances][:h] || 0.0, self[:distances][:a] || 0.0, self[:distances][:d] || 0.0]
    @current_distances.select { |distance| distance > @first_warning }.any?
  end

  def warning_level
    warning_2      = 75.0
    warning_3      = 100.0
    dis = @current_distances.select { |distance| distance > @first_warning }[0]
    @warning_level = if dis >= @first_warning && dis < warning_2
                       "Over 50% warning"
                     elsif dis >= warning_2 && dis < warning_3
                       "Over 75% warning"
                     elsif dis > warning_3
                       "Over 100% warning"
                     end
  end

  def available?
    self[:stat] != 'unavailable'
  end

  def unavailable?
    available?.!
  end

  def live?
    self[:is_running]
  end
end
