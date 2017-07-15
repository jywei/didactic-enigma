require 'test_helper'

class BettingResultTest < ActiveSupport::TestCase
  def setup
    @user         = create(:user)
    @match        = create(:random_match, :with_results)
    @offer_ou     = create(:default_offer, match: @match, name: "ou", head: 200)
  end

  def evaluate(me_name = "")
    target_order  = Order::Item.where(match_id: @match.id).first.order
    BettingResult.calculate(target_order)[0]
  end

  def test_ou_caculate
    create(:order, user: @user, offer: @offer_ou)
    assert_equal  :a,            evaluate[:result_target]
    assert_equal  :fail,         evaluate[:result_code]
  end

  def test_caculate_with_multiple_items_pass
    order         = create(:order, :with_parlay, user: @user, offer: @offer_ou)
    order.items.update_all(target: 'a')
    assert_equal  :pass,         evaluate[:result_code]
  end

  def test_caculate_with_multiple_items_fail
    create(:order, :with_parlay, user: @user, offer: @offer_ou)
    assert_equal  :fail,         evaluate[:result_code]
  end

  def test_ou_asian_caculate
    offer_ou_asian  = create(:default_offer, :with_h_handicapped_team, match: @match,
                             name: "ou", head: 198, asian_proportion: 70)
    order           = create(:order, user: @user, offer: offer_ou_asian)
    order.item.update!(type_flag: "asian")
    assert_equal    :d,          evaluate[:result_target]
    assert_equal    :draw,       evaluate[:result_code]
  end

  def test_ml_caculate
    offer_ml        = create(:default_offer, :with_h_handicapped_team, match: @match,
                             name: "ml", head: nil)
    create(:order, user: @user, offer: offer_ml)
    assert_equal    :h,          evaluate[:result_target]
    assert_equal    :pass,       evaluate[:result_code]
  end

  def test_three_way_caculate
    offer_three_way = create(:default_offer, match: @match, name: "three_way", head: nil)
    order           = create(:order, user: @user, offer: offer_three_way)
    order.item.update!(target: 'd')
    assert_equal    :h,          evaluate[:result_target]
    assert_equal    :fail,       evaluate[:result_code]
  end

  def test_three_way_draw_caculate
    match_draw       = create(:random_match, :with_draw_results)
    offer_three_way1 = create(:default_offer,
                              match: match_draw, name: "three_way",
                              head: nil)
    order            = create(:order, user: @user, offer: offer_three_way1)
    order.item.update!(target: 'd', odd: 0.98)
    target_order     = Order::Item.where(match_id: match_draw.id).first.order
    result_cal       = BettingResult.calculate(target_order)[0]
    assert_equal     :d,         result_cal[:result_target]
    assert_equal     :pass,      result_cal[:result_code]
  end

  def test_point_caculate
    offer_point      = @match.offers.find_by(name: 'point', head: 5.0) ||
                       create(:default_offer,
                              match: @match, name: "point",
                              head: 5.0)
    create(:order, user: @user, offer: offer_point)
    assert_equal     :h,         evaluate[:result_target]
    assert_equal     :pass,      evaluate[:result_code]
  end

  def test_point_asian_caculate
    existing_offer    = @match.offers.find_by(name: 'point', head: 2.0)
    offer_point_asian = if existing_offer
                          existing_offer.update_columns(asian_proportion: 70, handicapped_team: 'h')
                          existing_offer
                        else
                          create(:default_offer, :with_h_handicapped_team,
                                 match: @match, name: "point", head: 2.0,
                                 asian_proportion: 70)
                        end
    order             = create(:order, user: @user, offer: offer_point_asian)
    order.item.update!(type_flag: "asian", target: 'a')
    assert_equal      :d,        evaluate[:result_target]
    assert_equal      :draw,     evaluate[:result_code]
  end

  def test_odd_even_caculate
    offer_odd_even   = create(:default_offer, match: @match, name: "odd_even", head: nil)
    create(:order, user: @user, offer: offer_odd_even)
    assert_equal     :h,         evaluate[:result_target]
    assert_equal     :pass,      evaluate[:result_code]
  end

  def test_one_win_caculate
    offer_one_win    = create(:default_offer, match: @match, name: "one_win", head: 1.5)
    create(:order, user: @user, offer: offer_one_win)
    assert_equal     :h,         evaluate[:result_target]
    assert_equal     :pass,      evaluate[:result_code]
  end
end

