require 'test_helper'

class Order::AncestorTest < ActiveSupport::TestCase
  def setup
    db = ActiveRecord::Base.connection
    db.execute(File.read("db/fakers/users.sql"))
    db.execute(File.read("db/fakers/user_allotters.sql"))
    db.execute(File.read("db/fakers/user_ancestors.sql"))
    @user     = User.last
    @match    = create(:random_match, :with_results)
    @offer    = create(:offer, :with_category, :with_book_maker, match: @match, offer_category: @match.category.name)
    @order    = create(:order, user: @user, offer: @offer)
    @item     = @order.items.first
  end

  def evaluate(me_name = "")
    target_order  = Order::Item.where(match_id: @match.id).first.order
    item_updates  = BettingResult.calculate(target_order)
    item_updates.each do |item|
      @order.items.where(id: item[:id].to_i).update_all(result_target: item[:result_target].to_s, result_code: item[:result_code].to_s)
    end
    sweepstake_result = SweepStake.settled([target_order.reload])[0]
    @order.update!(settle: sweepstake_result[:settle], stake: sweepstake_result[:stake])
  end

  def test_profit_splitting_method
    evaluate
    sport_name = @item.sport_name
    Order::Ancestor.new.update_profit_splitting(@user.id, sport_name, @order)
    assert_equal @order.stake,          Order::Ancestor.first.member.to_f
    assert_equal (@order.stake * 0.05), Order::Ancestor.first.admin.to_f
    assert_equal (@order.stake * 0.05), Order::Ancestor.first.director.to_f
  end

end
