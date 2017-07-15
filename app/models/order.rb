# Order 儲存所有玩家注單，包含金額以及玩家的關聯，場次資訊則儲存在底下的 Order::Item 當中
class Order < ApplicationRecord
  has_many :items, class_name: 'Order::Item', dependent: :destroy
  has_one :order_ancestor, class_name: 'Order::Ancestor', dependent: :destroy
  has_one :vigorish_ancestor, class_name: 'VigorishAncestor', dependent: :destroy, primary_key: :id, foreign_key: :order_id
  belongs_to :user
  has_one :log_position, class_name: 'Log::Position'
  scope :with_data, -> { includes(:user, items: [:profile, :offer, {match: [:hteam, :ateam, category: :sport]}]) }
  scope :valid,     -> { where.not(is_valid: false) }

  midday = Time.now.midday
  midday = Time.now > midday ? midday : midday - 1.day
  scope :today,     -> { where("created_at BETWEEN ? AND ?", midday, midday + 1.day) }
  scope :paginate,  -> (page, per) { offset(per.to_i * (page.to_i - 1)).limit(per.to_i) }
  scope :settled,   -> (param) {
    if param == "true"
      where(settle: true)
    elsif param == "false"
      where(settle: false)
    else
      all
    end
  }

  def self.recent
    orders = all.includes(:order_ancestor, items: [:profile, :offer, match: [:category, :hteam, :ateam]]).order("created_at DESC")
    orders.map { |order| order.brief }
  end

  def brief
    {
      id:               id,
      amount:           amount,
      prize:            items_prize,
      items:            items.map(&:brief),
      order_at:         current_time_zone(created_at), # 歷史注單不用
      result_at:        current_time_zone(order_ancestor.try(:created_at)),
      effective_amount: effective_amount || 0,
      stake:            stake,
      remaining_quota:  current_quota,
      # 如果是串關單的話sport_id為0
      sport_id:         items.size > 1 ? 0 : items.first.sport_id
    }
  end

  def items_prize
    items.reduce(amount) { |result, item| result * (1 + item.odd) }.to_i - amount
  end

  def current_time_zone(time)
    time ? time.in_time_zone('Asia/Taipei').strftime("%m/%d %H:%M") : "01/02 03:04"
  end

  def self.history
    with_data.where.not(is_valid: false).order("id DESC").limit(100).map { |order| order.history }
  end

  def history
    {
      id:         id,
      is_parlay:  type_flag == "parlay",
      offer_type: items.first.offer_type,
      sport:      items.first.sport_name,
      order_time: created_at,
      account:    user,
      ip:         ip,
      price:      amount,
      items:      items.map(&:brief)
    }
  end

  def item
    i = items
    i.first
  end

  def item?
    items.size == 1
  end

  def create_items_with(order_items, offer_type)
    order_items.each do |order_item|
      match       = $redis.afu_match!(order_item[:match_id])
      offer       = match[offer_type][order_item[:offer]]
      t           = order_item[:team]
      type        = offer[:asian_new] ? :asian : :normal
      prop        = offer[:handicapped][:proportion]
      proportion  = t == offer[:head] ? prop : (prop * -1)
      sport       = match.db_match.category.sport
      items.create!(
        # odd:         offer[t.to_sym].to_f,
        odd:         order_item[:odd],
        offer:       offer.db_offer,
        match_id:    match.id,
        target:      t,
        head:        offer[:handicapped][:head],
        proportion:  proportion,   #head means handicap team
        offer_name:  offer[:type],
        type_flag:   type,
        sport_name:  sport.name,
        sport_id:    sport.id,
        ot_id:       offer_type_id(offer[:type], type_flag),
        category_id: match.meta[:category_id]
      )
    end
  end

  def create_items_profile
    items.includes(match: [:category, :hteam, :ateam]).each do |order_item|
      target_match = order_item.match
      order_item_profile = {
        order_item_id:    order_item.id,
        hteam_name:       target_match.hteam.display_name,
        ateam_name:       target_match.ateam.display_name,
        category_name:    target_match.category.name,
        match_start_time: target_match.start_time,
        halves:           target_match.halves
      }
      order_item.create_profile(order_item_profile)
    end
  end

  def offer_type_id(offer_type, type_flag)
    if type_flag == "normal"
      ::Offer::Type.where(offer_name: offer_type).normal.pluck(:id)[0]
    elsif type_flag == "running"
      ::Offer::Type.where(offer_name: offer_type).running.pluck(:id)[0]
    else
      ::Offer::Type.parlay.pluck(:id)[0]
    end
  end

  def self.summate_week_balances(time, week_name, params)
    sport_ids    = params[:sport_id].present? ? params[:sport_id].split(",") : nil
    type_ids     = params[:type_id].present? ? params[:type_id].split(",") : nil

    valid_orders = all.valid.includes(:items)
    week_orders  = valid_orders.select do |order|
      order.created_at.to_date.in?(time) &&
      order.sport_filter(sport_ids) &&
      order.type_filter(type_ids)
    end

    week = time.reverse_each.map do |day|
      orders = week_orders.select { |order| order.created_at.to_date.in? day..day }
      {
        name:             day.strftime("%m/%d ") + I18n.t(day.strftime("%A")),
        amount:           orders.sum(&:amount),
        effective_amount: orders.sum(&:amount),
        result:           orders.sum { |order| order.stake.to_i }
      }
    end

    week << {
      name:             week_name,
      amount:           week_orders.sum(&:amount),
      effective_amount: week_orders.sum(&:amount),
      result:           week_orders.sum { |order| order.stake.to_i }
    }

    week
  end

  def time_filter(time)
    return true unless time
    created_at.to_date.in? time
  end

  def sport_filter(sport_ids)
    return true unless sport_ids
    items.all? { |item| item.sport_id.to_s.in? sport_ids }
  end

  def type_filter(type_ids)
    return true unless type_ids
    return true if type_flag == "parlay" && type_ids.include?("13")
    [type_flag, item.offer_name].in? offer_names(type_ids)
  end

  def report_filter(sport_ids, type_ids, time)
    sport_filter(sport_ids) && type_filter(type_ids) && time_filter(time)
  end

  def self.report_filter(sport_ids, type_ids, time)
    select { |order| order.report_filter(sport_ids, type_ids, time) }.to_a
  end
  # 預計會加入取消及延賽
  Invalid_situation = ["draw"]

  def valid_amount
    user_items = []
    items.map { |item| user_items << item }
    user_items.map { |item|
      user_items.delete_at(user_items.index(item)) if item.result_code.in? Invalid_situation
    }
    return 0 if user_items.blank?
    amount
    # SweepStake.parlay(amount, user_items)
  end

  # sport_id列表：
  #
  # http://52.192.25.216:3000/api/v1/sports
  # 或是自己去DB看
  #
  # type_id列表：
  #
  # 讓分1
  # 大小2
  # 獨贏3
  # 三路4
  # 一輸二贏5
  # 單雙6
  # 波膽7
  # 滾球讓分8
  # 滾球大小9
  # 滾球獨贏10
  # 滾球單雙11
  # 滾球波膽12
  # 過關13
  def offer_names(type_ids)
    @offer_names ||=
      type_ids.map do |type_id|
        case type_id.to_i
        when 1
          ["normal", "point"]
        when 2
          ["normal", "ou"]
        when 3
          ["normal", "ml"]
        when 4
          ["normal", "three_way"]
        when 5
          ["normal", "one_win"]
        when 6
          ["normal", "odd_even"]
        when 7
          ["normal", "correct_socre"]
        when 8
          ["running", "point"]
        when 9
          ["running", "ou"]
        when 10
          ["running", "ml"]
        when 11
          ["running", "odd_even"]
        when 12
          ["running", "correct_socre"]
        end
      end
  end

  def self.statistic_order(time, sports, settled_orders, unsettled_orders)
    time_range = time..(time + 1.day)
    {
      date: time.strftime("%Y-%m-%d"),
      reports: sports.map do |sport|
        same_sport_settled_orders   = Order.orders_in(settled_orders, time_range, sport.id)
        same_sport_unsettled_orders = Order.orders_in(unsettled_orders, time_range, sport.id)
        {
          name:      sport.display_name,
          settled:   same_sport_settled_orders.sum(&:amount),
          unsettled: same_sport_unsettled_orders.sum(&:amount)
        }
      end
    }
  end

  def self.orders_in(orders, time_range, sport_id)
    orders.select do |order|
      order.item.profile.match_start_time.in?(time_range) &&
      order.item.sport_id == sport_id
    end
  end
end
