require 'test_helper'

class SweepStakeTest < ActiveSupport::TestCase
  def setup
    @user             = create(:user)
    @match            = create(:random_match, :with_results)
    @item = Struct.new(:type_flag, :odd, :result_code, :proportion)
  end

  def test_parlay_in_sweep_stake
    arr_all_pass  = []
    arr_all_pass  << @item.new(:normal, 0.95, :pass) \
                  << @item.new(:asian, 0.95, :pass, 20) \
                  << @item.new(:normal, 0.97, :pass) \
                  << @item.new(:asian, 0.95, :pass, -40)
    assert_equal 1361, SweepStake.parlay(100, arr_all_pass)
  end

  def test_parlay_with_all_draws
    arr_all_draws  = []
    arr_all_draws  << @item.new(:normal, 0.95, :draw) \
                   << @item.new(:asian, 0.95, :draw, 20) \
                   << @item.new(:normal, 0.97, :draw) \
                   << @item.new(:asian, 0.95, :draw, -40)
    assert_equal -29, SweepStake.parlay(100, arr_all_draws)
  end

  def test_parlay_with_draw
    arr_with_draws  = []
    arr_with_draws  << @item.new(:normal, 0.95, :pass) \
                    << @item.new(:asian, 0.95, :draw, 20) \
                    << @item.new(:normal, 0.97, :draw) \
                    << @item.new(:asian, 0.95, :pass, -40)
    assert_equal 353, SweepStake.parlay(100, arr_with_draws)
  end

  def test_parlay_sweep_stake_settled_fail
    offer_ou      = create(:offer, :with_category, :with_book_maker, match: @match, name: "ou", head: 200)
    order         = create(:order, :with_parlay, user: @user, offer: offer_ou)
    item_updates  = BettingResult.calculate(order)
    item_updates.each do |item|
      order.items.where(id: item[:id].to_i).update_all(result_target: item[:result_target].to_s, result_code: item[:result_code].to_s)
    end
    assert_equal -100, SweepStake.settled([order.reload])[0][:stake]
  end

  def test_parlay_sweep_stake_settled
    offer_ou      = create(:offer, :with_category, :with_book_maker, match: @match, name: "ou", head: 200)
    order         = create(:order, :with_parlay, user: @user, offer: offer_ou)
    order.items.update_all(target: 'a')
    item_updates = BettingResult.calculate(order)
    item_updates.each do |item|
      order.items.where(id: item[:id].to_i).update_all(result_target: item[:result_target].to_s, result_code: item[:result_code].to_s)
    end
    assert_equal 642, SweepStake.settled([order.reload])[0][:stake]
  end

end
