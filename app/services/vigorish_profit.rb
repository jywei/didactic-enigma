class VigorishProfit
  include ShareInfo

  Tiers = UserReport.tier_name(0, :en)
  def initialize(ancestor, order, type)
    @ancestor   = ancestor
    @order      = order
    @type       = type
    @sport_name = sport_name_parser(ancestor[:sport_name])
  end

  def share_info
    result = if (@type == "ancestor")
               ancestor_calculate
             elsif (@type == "profit")
               profit_calculate
             end
    {
      order_id:           @order.id,
      user_id:            @order.user_id,
      admin:              result[0],
      moderator:          result[1],
      supervisor:         result[2],
      director:           result[3],
      major_shareholder:  result[4],
      shareholder:        result[5],
      general_agent:      result[6],
      agent:              result[7],
      member:             result[8],
      sport_name:         @sport_name,
      result_flag:        @ancestor[:result_flag],
      total_vigorish:     @ancestor[:total_vigorish]
    }
  end

  def ancestor_calculate
    tier_result = []
    result = []
    Tiers.map do |tier|
      tier_result << @ancestor[tier.to_sym].to_f
    end
    result << 0
    array_substract(tier_result, result)
  end

  def profit_calculate
    shares = share_interval(ancestor_shares(@order.user_id, @sport_name))
    profit_result = get_value(share_cut(@order.stake, shares)).to_a
    profit_result = deal_with_sign(profit_result)
    result = profit_result.zip(get_value(@ancestor.to_a[4..-2]).reverse).map{ |arr| arr.reduce(&:+).round(2) } # make tags incase of using in the future
    result = final_profit_calculate(result.reverse)
    result
  end

  def final_profit_calculate(profit)
    result = []
    set_negative(0, profit)
    result << profit.shift.to_f
    result = array_substract(profit, result)
    set_negative(0, result)
    result << 0
    result.reverse
  end

  def set_negative(index, result)
    result[index] = - result[index]
  end

  def array_substract(original, result)
    while(original.length != 1)
      result << (result[-1].to_f - original[0].to_f).round(2)
      original.shift
    end
    result
  end

  # add (-) for tier 0..7 for report using
  def deal_with_sign(profit)
    profit.each_with_index do |value, index|
      profit[index] = - value unless index == profit.size - 1
    end
    profit
  end

  def get_value(arr)
    arr.map{ |item| item[1] }
  end

  def sport_name_parser(sport_name)
    sport_name = sport_name.slice(3..-1) if sport_name[0..1] == "ht"
    sport_name
  end
end
