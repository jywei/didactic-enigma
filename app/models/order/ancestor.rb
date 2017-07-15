# Order::Ancestor 專門儲存每一筆訂單在每一階層會賺或付多少錢
class Order::Ancestor < ApplicationRecord
  belongs_to :order

  include ShareInfo

  def update_profit_splitting(user_id, sport_name, order)
    sport_name.include?('baseball') && sport_name = "us_baseball"
    shares = share_interval(ancestor_shares(user_id, sport_name))
    assign_attributes(share_cut(order.stake, shares))
    general_update(order, sport_name)
    save!
    order.update!(split: true)
  end

  def ancestor_shares(user_id, sport_name)
    ancestorz_arr = User::Ancestor.member.upperlines(user_id).attributes.values[1..-1]
    oppos = User::Allotter.where("name = ? AND user_id in (?)", sport_name, ancestorz_arr).order(user_id: :desc).pluck(:oppo).map(&:to_f)
    oppos
  end

  def general_update(order, sport_name)
    self.order_id    = order.id
    self.result_flag = if order.stake == 0
                         "draw"
                       elsif order.stake > 0
                         "win"
                       else
                         "lose"
                       end
    self.sport_name  = sport_name
  end

end
