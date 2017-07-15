# 儲存於Redis當中的比賽格式，方便前端拉取API時直接將資料格式吐出去
#
# 若要產生一組資料，API設計上是由 Match::Open::Builder#to_open 將一筆 Match 資料轉為 match/open
#
# ```ruby
# match = Match.last
# match.to_open
# ```
#
# 或是可以直接存到Redis當中：
#
# ```ruby
# match.open!
# ```
#
# 從Redis當中取得 match/open ：
#
# ```ruby
# match = Match.last
#
# $redis.afu_match(match.id)
# # 或是
# match.afu
# ```
#
class Match::Open < ActiveSupport::HashWithIndifferentAccess
  autoload :'Group', File.expand_path("../open/group.rb", __FILE__)

  include Serializer
  extend  Query

  attr_accessor :meta, :db_match

  # 產生新的cache格式比賽
  #
  # 參數：
  #
  # - match: Match 儲存在db裡面的match
  # - args: Hash 包含兩個資料: {
  #   data: Hash (顯示於前端),
  #   meta: Hash (純粹後端使用)
  # }
  #
  #
  # 目前都是藉由 Match::Open::Builder#to_open 直接將一場match轉為match/open：
  #
  # ```ruby
  # match = Match.last
  # match.to_open
  # ```
  def initialize(match, args = {data: {}, meta: {}})
    args[:data].each { |k, _| self[k] = args[:data][k] }
    @meta     = args[:meta]
    @db_match = match
  end

  # 重新從Redis當中讀取
  def reload
    $redis.afu_match!(key)
  end

  # 把目前的整包比賽存到redis當中
  #
  # 如果之前已經儲存過，就會回傳false，如果是一場新的比賽，就會回傳true
  def save!
    $redis.db.hset($matches_key, key, Marshal.dump(self))
  end

  # 調整比賽底下其中一個玩法的賠率
  #
  # 參數：
  #
  # ```ruby
  # {
  #   offer: String,
  #   type: String, # => 隊伍 'h', 'a', or 'asian'
  #   modifier: Float,
  #   variant: String, # => 'normal' or 'parlay'
  # }
  # ```
  def update_odd!(args)
    @args = args.with_indifferent_access
    redis_offer = offers[offer_name]
    db_offer = redis_offer.db_offer
    update_modifier(db_offer, redis_offer)
    update_parlay if series?
    true
  end

  # 從參數取得參數類別
  def arg_type
    @args[:type]
  end

  # 更新特定玩法的賠率調整值
  #
  # 參數：
  #
  # - db_offer: Offer
  # - redis_offer: Offer::Open
  #
  def update_modifier(db_offer, redis_offer)
    arg_type == "asian" ? update_redis_prop(redis_offer) : update_redis_modifier(redis_offer)
    update_db_offer(db_offer)
    Rails.logger.info("#{Thread.current.object_id}: 套用#{arg_type}賠率調整值: #{modifier}")
  end

  # 修改特定玩法的狀態
  #
  # 參數：
  #
  # ```ruby
  # {
  #   offer: 玩法名稱("ou", "point")或"all",
  #   stat: "normal"或"disabled"或"paused"
  # }
  # ```
  def change_stat!(args)
    args = args.with_indifferent_access
    change_redis_stat(args)
    change_db_stat(args)
  end

  # 將目標資料庫的offer轉換為offer/open並儲存到本場比賽的特定玩法上，並儲存到Redis內。
  #
  # 參數：
  #
  # ```ruby
  # match = Match.last.to_open
  # offer = Offer.find_by(match_id: match)
  #
  # match.assign!(offer, match.key)
  # ```
  def assign!(db_offer, match_key)
    assign_offer(:play, db_offer, match_key)
    db_offer.update_parlay if db_offer.parlay.nil?
    assign_offer(:parlay, db_offer.reload.parlay, match_key)
    save!
  end

  # 找到特定玩法在資料庫內最平球頭的玩法
  #
  # ```ruby
  # match = Match.last.to_open
  # match.find_flat("point")
  # # => #<Offer:0x007fd92f3ac4c8>
  # ```
  def find_flat(offer_name)
    ::Offer.where(match_id: id).flat(offer_name).to_open
  end

  # 根據訂單來調整特定玩法的部位
  #
  # 參數：
  #
  # ```ruby
  # {
  #   amount: 20000,
  #   prize: 50000,
  #   rate_mode: 'any',
  #   match_id: 1234,
  #   team: "h",
  #   offer: "point",
  #   odd: 0.97
  # }
  # ```
  def adjust_position_from_orders!(args)
    stake       = "#{args[:team]}_stake".to_sym
    self[stake] += args[:amount].to_i
    self[:play][args[:offer].to_sym].update_from_order(args)
    save!
  end

  # 根據門檻的移動來調整特定玩法的部位
  #
  # 參數同 #adjust_position_from_orders!
  #
  def adjust_position_from_thresholds!(args)
    self[:play][args[:offer]].update_from_thresholds(args)
    save!
  end

  # 判斷這場比賽是否有平手的賭金存在，一般來說只會有足球的場次
  def d?
    self[:d_stake].present?
  end

  # 取得這場比賽底下的所有一般玩法
  def offers
    self[:play]
  end

  # 取得這場比賽底下的所有串關玩法
  def parlays
    self[:parlay]
  end

  # 將底下所有一般玩法拉出來塞入一個空的 Hash，用於紀錄timestamp使用
  #
  # ```ruby
  # match = Match.last.to_open
  # match.default_offer_timestamp
  # # => {"three_way"=>{}, "point"=>{}, "ou"=>{}, "one_win"=>{}, "odd_even"=>{}}
  # ```
  def default_offer_timestamp
    self[:play].each_with_object({}) { |offer, result| result[offer[0]] = {} }
  end

  # 取得自己在資料庫中的比賽id
  def id
    self[:id]
  end

  # 取得自己在Redis當中的id
  def key
    self[:match_id]
  end

  # 移除指定的offer類別，指一般或串關，用於準備丟到前端時，看前端指定是要串關賠率或是一般賠率
  #
  # 參數：
  #
  # - type: Symbol 應為 :play 或 :parlay
  #
  def remove_offer_type(type = :parlay)
    case type
    when :parlay
      delete(:parlay)
      meta[:parlay] = true
    when :play
      delete(:play)
      self[:play] = self[:parlay]
      delete(:parlay)
      meta[:parlay] = true
    end
  end

  # 利用這場比賽內的資料，轉換為 Group 要吐到前端的資料格式
  def to_group
    open_group = Group.new
    keys = %i(
      start_time
      start_time_int
      sport
      team
      h_score
      a_score
      h_stake
      a_stake
      d_stake
      match_result
      is_running
      book_maker
      group_id
    )
    keys.each {|k| open_group[k] = self[k] }
    open_group[:match_id] = self[:_match_id]
    open_group[:halves_matches] = {}
    open_group
  end

  # 如果這場比賽要吐到前端的資料是依附在 Group 底下，則刪除其他資料，僅保留部分賠率相關資訊
  def to_group_match
    keep(*%w(
         match_id
         _halves_match_id
         match_number
         halves
         play
         parlay
         h_stake
         a_stake
         h_score
         a_score
         stat
        ))
  end

  # 判斷這場比賽是否已經在資料庫有資料
  def available?
    meta[:available]
  end

  # 將目標資料庫的offer轉換為offer/open並儲存至指定的玩法類別上
  def assign_offer(type, db_offer, match_key)
    self[type][db_offer.name] = db_offer.to_open(match_key)
  end

  %w(ml three_way ou one_win point odd_even).each do |m|
    define_method m.to_sym do
      self[:play][m.to_sym]
    end
  end

  %w(ml three_way ou one_win point odd_even).each do |m|
    define_method ('parlay_' + m.to_s).to_sym do
      self[:parlay][m.to_sym]
    end
  end

  protected

    # 從資料庫撈取串關盤資料，並更新於特定玩法上
    def update_parlay
      redis_offer = parlays[offer_name]
      db_offer = Offer::Parlay.find(redis_offer[:parlay_id])
      update_modifier(db_offer, redis_offer)
    end

    # 從參數取得offer名稱
    def offer_name
      @args[:offer].to_sym
    end

    # 從參數取得modifier值
    def modifier
      @args[:modifier].to_f
    end

    # 判斷此場比賽底下的特定玩法是否有和串關連動
    def series?
      offers[@args['offer']][:series]
    end

    # 將目前特定玩法的賠率調整值更新到資料庫內
    def update_db_offer(offer)
      offer.update_attributes({ "#{arg_type}_modifier" => modifier })
    end

    # 將目前特定玩法的球頭調整值更新到Redis內
    #
    # 參數：
    #
    # - offer: Offer::Open
    #
    def update_redis_prop(offer)
      offer[:handicapped][:modifier] = modifier
      save!
    end

    # 將目前特定玩法的賠率調整值更新到Redis內
    #
    # 參數：
    #
    # - offer: Offer::Open
    #
    def update_redis_modifier(offer)
      offer["#{arg_type}_modifier"] = modifier
      save!
    end

    # 修改特定玩法在Redis內的狀態
    def change_redis_stat(args)
      if args[:offer] == 'all'
        self[:stat] = args[:stat]
      else
        self[:play][args[:offer]]['stat'] = args[:stat]
        self[:parlay][args[:offer]]['stat'] = args[:stat]
      end
      save!
    end

    # 修改特定玩法在資料庫內的狀態
    def change_db_stat(args)
      new_stat = args[:stat]
      current_match = Match.find(self['id'])
      if args[:offer] == 'all'
        current_match.offers.update_all(stat: new_stat)
        current_match.update!(stat: new_stat)
      else
        offer = self[:play][args[:offer]]
        current_offers = current_match.offers.where(name: offer['type'])
        raise "Match has no offer name #{offer['type']}" if current_offers.empty?
        current_offers.update_all(stat: new_stat)
      end
    end

end
