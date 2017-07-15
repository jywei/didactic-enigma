namespace :order do
  task place_order: :environment do
    users = User.where("username in (?)", ['tier8-1', 'tier8-2', 'tier8-3', 'tier8-4'])
    target_matches = Match.active.to_a.sample(50)
    target_matches.each do |match|
      target_offer = match.offers.sample
      order = ::Order.new(
        time:          Time.now,
        amount:        (1_000..10_000).step(500).to_a.sample,
        user:          users.sample,
        type_flag:     'normal',
        is_valid:      true
      )
      order.save!
      chosen_team = %w(h a).sample
      order_item = {
        match_id: match.key,
        team: chosen_team,
        offer: target_offer.name,
        asia_proportion: target_offer.try(:asia_proportion) || nil,
        odd: target_offer.send("#{chosen_team}_odd".to_sym)
      }
      redis_match = $redis.afu_match!(order_item[:match_id])
      offer       = redis_match["play"][order_item[:offer]]
      type        = offer[:asian_new] ? :asian : :normal
      prop        = offer[:handicapped][:proportion]
      proportion  = order_item[:team] == offer[:head] ? prop : (prop * -1)
      order.items.create!(
        odd:          offer[order_item[:team].to_sym].to_f,
        offer:        offer.db_offer,
        match_id:     redis_match.id,
        target:       order_item[:team],
        head:         offer[:handicapped][:head],
        proportion:   proportion,
        offer_name:   offer[:type],
        type_flag:    type,
        sport_name:   redis_match.db_match.category.sport.name,
        sport_id:     redis_match.db_match.category.sport.id,
        ot_id:        order.offer_type_id(offer[:type], type),
        category_id:  redis_match.meta[:category_id]
      )
      # add
      order.items.includes(match: [:category, :hteam, :ateam]).each do |item|
        target_match = item.match
        order_item_profile = {
          order_item_id:    item.id,
          hteam_name:       target_match.hteam.display_name,
          ateam_name:       target_match.ateam.display_name,
          category_name:    target_match.category.name,
          match_start_time: target_match.start_time,
          halves:           target_match.halves
        }
        item.create_profile(order_item_profile)
      end
    end
  end

  task update_scores: :environment do
    users = User.where("username in (?)", ['tier8-1', 'tier8-2', 'tier8-3', 'tier8-4'])
    score = [ [100, 98], [97, 100], [100, 100], [100, 100]]
    match_ids = Order::Item.where("order_id in (?)", Order.where("user_id in (?)", users.pluck(:id)).pluck(:id)).pluck(:match_id)
    match_id_size = match_ids.size
    score.each do |val|
      val[2] = match_ids.shift((match_id_size * 0.33).round)
      Match.where("id in (?)", val[2]).update_all(h_score: val[0], a_score: val[1])
    end
  end

  task calculate_results: :environment do
    users = User.where("username in (?)", ['tier8-1', 'tier8-2', 'tier8-3', 'tier8-4'])
    target_orders = Order.where("user_id in (?)", users.pluck(:id))
    target_orders.each do |order|
      update_hash = BettingResult.calculate(order)[0]
      order.items.where(id: update_hash[:id].to_i).update_all(result_target: update_hash[:result_target].to_s, result_code: update_hash[:result_code].to_s)
      sweepstake_result = SweepStake.settled([order.reload])[0]
      order.update!(settle: sweepstake_result[:settle], stake: sweepstake_result[:stake])
      sport_name = order.items.first.sport_name
      Order::Ancestor.new.update_profit_splitting(order.user_id, sport_name, order)
    end
  end

  task clean_test_data: :environment do
    users = User.where("username in (?)", ['tier8-1', 'tier8-2', 'tier8-3', 'tier8-4'])
    target_orders = Order.where("user_id in (?)", users.pluck(:id))
    splitted_orders = Order::Ancestor.where("order_id in (?)", Order.where("user_id in (?)", users.pluck(:id)).pluck(:id))
    target_orders.destroy_all
    splitted_orders.destroy_all
    puts "TEST: Mock order data are all deleted"
  end

  task from_place_to_calculate: [:place, :update_scores, :calculate_results, :vigorish_split_fake] do
    puts "TEST: Placing orders to calculation is completed"
  end

  # 跟 calculate_order.rake vigorish_split 一樣
  task vigorish_split_fake: :environment do
    order_ids = Order::Item.where("vigorish_split = FALSE OR vigorish_split is NULL AND sport_name != 'test'").pluck(:order_id)
    orders = Order.includes(:items).where("vigorish_split = FALSE OR vigorish_split is NULL AND settle = TRUE").where("id in (?)", order_ids)
    orders.each do |order|
      puts "id: #{order.id} started calculate"
      data = VigorishAncestor::Runner.new(order).split
      share_data = VigorishProfit.new(data, order, "ancestor").share_info
      profit_data = VigorishProfit.new(data, order, "profit").share_info
      VigorishAncestor.create!(data)
      VigorishShare.create!(share_data)
      TotalProfit.create!(profit_data)
      order.update_column(:vigorish_split, true)
      order.items.update_all(vigorish_split: true)
      puts "id: #{order.id} ended calculate"
    end
  end

  task vigorish_reset: :environment do
    Order.update_all(vigorish_split: false)
    Order::Item.update_all(vigorish_split: false)
    VigorishAncestor.destroy_all
    VigorishShare.destroy_all
    TotalProfit.destroy_all
  end

  task place: :environment do
    users           = User.where("username in (?)", ['tier8-1', 'tier8-2', 'tier8-3', 'tier8-4'])
    target_matches  = Match.active.to_a.sample(20)
    target_matches.each do |match|
      if match.category.sport.name != 'test'
        redis_match = $redis.afu_match!(match.id)
        offer_name  = match.offers.sample.name
        offer       = redis_match["play"][offer_name]
        amount      = (1_000..10_000).step(500).to_a.sample
        team        = %w(h a).sample
        odd         = offer[team.to_sym]
        puts "#{offer_name}"
        puts "#{offer}"
        puts "#{amount}"
        puts "#{team}"
        puts "#{odd}"
        order = {
          amount: amount,
          prize:  amount * odd,
          rate_mode: 'any',
          items: [
            {
              match_id: match.redis_id,
              team: team,
              offer: offer_name,
              odd: odd
            }
          ]
        }
        puts "#{order}"
        Operation::Order.new(order, users.sample, nil, nil, '9.4.8.7', true).place!
      end # if
    end  # each
  end # task
end
