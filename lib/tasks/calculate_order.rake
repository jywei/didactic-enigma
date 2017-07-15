# order job redis key "$redis_key_prefix/order_jobs"
# use redis struct is list
# redis push data use rpush / pop data use lpop
#
namespace :order do
  task settled: :environment do
    @key = "#{$redis_key_prefix}/order_jobs"
    @update_result = ->(item) { Order::Item.find(item[:id]).update(result_code: item[:result_code], result_target: item[:result_target]) }
    @update_stake = ->(order) { Order.find(order[:id]).update(stake: order[:stake], settle: order[:settle]) }
    loop do
      while match_id = $redis.db.lpop(@key)
        items = Order::Item.where(match_id: match_id)
        BettingResult.calculate(items).each { |item| @update_result.call(item) }
        orders = Order.includes(:items).where("id IN (?)", items.pluck(:order_id))
        SweepStake.settled(orders).each { |order| @update_stake.call(order) }
      end
    end
  end

  task vigorish_split: :environment do
    loop do
      order_ids = Order::Item.where("vigorish_split = FALSE OR vigorish_split is NULL AND sport_name != 'test'").pluck(:order_id)
      orders = Order.includes(:items).where("vigorish_split = FALSE OR vigorish_split is NULL AND settle = TRUE").where("id in (?)", order_ids)
      orders.each do |order|
        data = VigorishAncestor::Runner.new(order).split
        share_data = VigorishProfit.new(data, order, "ancestor").share_info
        profit_data = VigorishProfit.new(data, order, "profit").share_info
        VigorishAncestor.create!(data)
        VigorishShare.create!(share_data)
        TotalProfit.create!(profit_data)
        order.update_column(:vigorish_split, true)
        order.items.update_all(vigorish_split: true)
      end
    end
  end

  task profit_share: :environment do
    loop do
      orders = Order.where(settle: true).where('split = FALSE OR split is NULL')
      orders.each do |order|
        if order.type_flag != "parlay"
          sport_name = order.items.first.sport_name
          Order::Ancestor.new.update_profit_splitting(order.user_id, sport_name, order)
        end
      end
    end
  end

end
