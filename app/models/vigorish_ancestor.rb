class VigorishAncestor < ApplicationRecord
  belongs_to :order, class_name: "Order", primary_key: :id, foreign_key: :order_id

  class Runner
    def initialize(order)
      @order   = order
      @item    = @order.items.first
      @user_id = @order.user_id
      @ot_it   = @item.ot_id
    end

    def split
      @sport_name = @item.sport_name
      @sport_name = "us_baseball" if @sport_name.include?('baseball')
      @setting_sport_name = sport_name_parser(@sport_name, @item.match.halves)
      result_flag = if @order.stake == 0
                      "draw"
                    elsif @order.stake > 0
                      "win"
                    else
                      "lose"
                    end
      general_info =  {
                        order_id:       @order.id,
                        result_flag:    result_flag,
                        sport_name:     @setting_sport_name,
                        halves:         @item.match.halves
                      }
      general_info.merge!(runner)
    end

    def runner
      if @item.result_code == "pass" && @order.type_flag == "parlay"
        vigorish_tree(0, 0, 0)
      else
        @ancestorz_arr = User.find(@user_id).line_ids.unshift(@user_id)
        rebates = User::Setting.where("name = ? AND ot_id = ? AND user_id in (?)", @setting_sport_name, @ot_it, @ancestorz_arr).rebates
        # rebates = User::Setting.where(sport_id: @item.sport_id, halves: halves_parser(@item.profile.halves), category_id: @item.category_id, ot_id: @ot_it, user_id: @ancestorz_arr).rebates
        puts "#{@order.id} rebates is nil " if rebates.blank?
        oppos = User::Allotter.where(name: @sport_name, user_id: @ancestorz_arr[1..-1]).oppos
        vigorish_rate = rebates[-1]
        rebate_rates = rebates.map { |a| a / vigorish_rate }
        @total_vigorish = (@order.amount * vigorish_rate / 10_000)

        provider = vigorish_calculator(oppos, -1)
        receiver = vigorish_calculator(rebate_rates, 1)

        result = provider.merge!(receiver) { |key, value1, value2| (value1 + value2).round(3) }
        result.merge!(total_vigorish: @total_vigorish)
        result
      end
    end

    def vigorish_calculator(shares, factor)
      vigorish_provide_shares = share_calculator(shares)
      vigorish_tree(vigorish_provide_shares, factor)
    end

    def share_calculator(shares)
      share_interval(shares) if shares.any?
    end

    def sport_name_parser(sport_name, halves)
      (sport_name = "ht_" + sport_name) if halves == "ht"
      sport_name
    end

    # def halves_parser(halves)
    #   nil unless halves == "ht"
    # end

    def vigorish_tree(shares, factor)
      shares.unshift(0.0) if factor == -1
      tmp = ->(e) { (e * @total_vigorish * factor).round(3) }
      shares_amount = shares.map(&tmp)
      {
        member:            shares_amount[0],
        agent:             shares_amount[1],
        general_agent:     shares_amount[2],
        shareholder:       shares_amount[3],
        major_shareholder: shares_amount[4],
        director:          shares_amount[5],
        supervisor:        shares_amount[6],
        moderator:         shares_amount[7],
        admin:             shares_amount[8]
      }
    end

    def share_interval(oppos)
      max_length = oppos.length
      tmp = []
      while(oppos.length != 1)
        tmp << oppos[0].to_f.round(3) if oppos.length == max_length
        tmp << (oppos[1].to_f - oppos[0].to_f).round(3)
        oppos.shift
      end
      tmp
    end

  end
end
