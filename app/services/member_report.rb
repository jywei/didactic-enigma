class MemberReport
  include ShareInfo

  def initialize(params)
    @params           = params
    @user             = User.find(params[:id])
    @orders           = Order.includes(:items).where(user_id: params[:id]).where(vigorish_split: true)
    @sports           = Hash[Sport.active.pluck(:name, :ch).to_a]
    @vigorish_shares  = VigorishShare.includes(:order).where(order_id: @orders).to_a
    @total_profits    = TotalProfit.includes(:order).where(order_id: @orders).to_a
    ancestorz_arr     = User::Ancestor.member.upperlines(params[:id]).attributes.values[1..-1]
    @allotters        = User::Allotter.where("user_id in (?)", ancestorz_arr).order(user_id: :desc)
  end

  def serialize
    {
      data: @orders.map {|order| element(order)}
    }
  end

  def element(order)
    ancestor     = @vigorish_shares.select{ |share| share.order_id == order.id}[0]
    total_profit = @total_profits.select{ |profit| profit.order_id == order.id}[0]
    win_lose     = SweepStake.parlay(order.amount, order.items)
    valid_amount = order.valid_amount
    {
      time:         order.created_at,
      id:           order.id,
      ip:           order.ip,
      content:      content(order.items),
      amount:       order.amount,
      valid_amount: valid_amount,
      win_lose:     check_valid(valid_amount, win_lose),
      ancestors:    ancestors(order, ancestor, total_profit),
      note:         order.parlay_count, # fake
      device:       order.parlay_count  # fake
    }
  end

  def check_valid(valid_amount, value)
    valid_amount.equal?(0) ? 0 : value
  end

  def content(items)
    items.map do |item|
     {
      name:   @sports["#{item.sport_name}"],
      offer:  Info::OddTypePush.name_to_ch(item.offer_name),
      info:   item.brief
     }
    end
  end

  def ancestors(order, ancestor, profit)
    tier_names = arrange_arr(UserReport.names)
    allotters  = @allotters.select{ |allotter| allotter.name == order.items.first.sport_name }.pluck(:oppo).map(&:to_f)
    tier_names.map do |tier_name|
      {
        name:     UserReport.downline_lang_chart[tier_name],
        shares:   ancestor[tier_name].to_f,
        result:   profit[tier_name].to_f,
        allotter: tier_name == "member" ? nil : allotters[tier_names.index(tier_name)]
      }
    end
  end

  # arrange array for shift or pop
  def arrange_arr(arr)
    arr.shift
    arr
  end
end
