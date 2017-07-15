require 'test_helper'

class Operation::OrderTest < ActiveSupport::TestCase
  def setup
    @user              = create(:user)
    @user_profile      = create(:user_profile, user_id: @user.id)
    @player_channel    = "user_#{SecureRandom.hex(5)}"
    @user_channel      = "user_#{SecureRandom.hex(5)}"
    @match             = create(:match, :with_offers, :with_category, :with_team, :with_book_maker, :with_group)
    @asian             = create(:match, :with_offers, :with_category, :with_team, :with_book_maker, :with_group, :with_asian_offers, match_category: :mlb)
    @combination_match = create(:match, :with_offers, :with_category, :with_team, :with_book_maker, :with_group, :with_invalid_offers)
    @open              = @match.to_open
    @asian_open        = @asian.to_open
    @combination_open  = @combination_match.to_open
    @match.open!
    @asian.open!
    @combination_match.open!
    db = ActiveRecord::Base.connection
    db.execute(File.read("db/fakers/offer_types.sql"))
  end

  def args( rate_mode = 'normal', odd = 0 )
    {
      amount:    1_250,
      prize:     1_162,
      rate_mode: rate_mode,
      items: [
        {
          match_id:  @match.key,
          team:      'h',
          offer:     'ml',
          odd:       odd
        }
      ]
    }
  end

  def parlay_args(parlay_serial = nil, parlay_count = nil)
    {
      amount:        20_000,
      prize:         50_000,
      rate_mode:     'any',
      items:         [],
      parlay_serial: parlay_serial,
      parlay_count:  parlay_count
    }
  end

  def parlay_item(match, team, offer, open, asia_proportion = nil)
    offer_team = open[:parlay]["#{offer}"]
    {
      match_id:        match.key,
      team:            team,
      offer:           offer,
      asia_proportion: asia_proportion,
      odd:             offer_team["#{team}"] + offer_team["#{team}_modifier"]
    }
  end

  def parlay_combination_args(offer1, offer2)
    parlay_combination = parlay_args('t25689', 3)
    parlay_combination[:items] << parlay_item(@combination_match, 'h', offer1, @combination_open)
    parlay_combination[:items] << parlay_item(@combination_match, 'h', offer2, @combination_open)
    parlay_combination
  end

  def place_order(msg)
    Operation::Order.new(msg, @user, @player_channel, @user_channel, '127.0.0.1').place!
  end

  def test_place_rate_mode_normal_success
    a = args('normal', @open.ml[:h] + @open.ml[:h_modifier] )
    place_order(a)
    assert_equal 1,                                               ::Order.count
    assert_equal 1,                                               ::Order::Item.count
    assert_equal 1,                                               ::Order::Item::Profile.count
    order = ::Order.first
    assert_equal '127.0.0.1',                                     order.ip
    assert_equal 1_250,                                           order.amount
    assert_equal 998_750,                                         order.current_quota
    assert_equal 1_250,                                           order.valid_amount
    item = ::Order::Item.first
    assert_equal (@open.ml[:h] + @open.ml[:h_modifier]).round(3), item.odd.to_f.round(3)
    assert_equal @open.ml[:handicapped][:head],                   item.head.to_f.round(3)
    assert_equal @open.ml[:handicapped][:proportion],             item.proportion.to_f.round(3)
    assert_nil   @open.ml[:d]
    assert_equal @match.hteam.display_name,                       item.profile.hteam_name
    assert_equal 3,                                               item.ot_id
    assert_equal @match.category_id,                              item.category_id
  end

  def test_place_rate_mode_default_failed
    a = args('normal', @open.ml[:h] + @open.ml[:h_modifier] - 0.05 )
    place_order(a)
    assert_equal 0, ::Order.count
    assert_equal 0, ::Order::Item.count
    assert_equal 0, ::Order::Item::Profile.count
  end

  def test_place_rate_mode_best_success
    a = args('best', @open.ml[:h] + @open.ml[:h_modifier] + 0.05 )
    place_order(a)
    assert_equal 1, ::Order.count
    assert_equal 1, ::Order::Item.count
    assert_equal 1, ::Order::Item::Profile.count
  end

  def test_place_rate_mode_best_failed
    a = args('best',@open.ml[:h] + @open.ml[:h_modifier] - 0.05 )
    place_order(a)
    assert_equal 0, ::Order.count
    assert_equal 0, ::Order::Item.count
    assert_equal 0, ::Order::Item::Profile.count
  end

  def test_place_parlay_order_build_order_success
    a = parlay_args
    a[:items] << parlay_item(@match, 'h', 'point', @open)
    a[:items] << parlay_item(@asian, 'h', 'ml', @asian_open)
    place_order(a)
    assert_equal 1, ::Order.count
    assert_equal 2, ::Order::Item.count
    assert_equal 2, ::Order::Item::Profile.count
  end

  def test_parlay_combinations_build_order_success
    combination = ["ml", "point", "ou"].permutation(2).to_a.sample(3)
    combination.each do |ele|
      parlay = parlay_combination_args(ele[0], ele[1])
      place_order(parlay)
    end
    assert_equal 3, ::Order.count
    Order.all.each do |order|
      assert_equal 3, order.parlay_count
      assert_equal 't25689', order.parlay_serial
    end
  end

  def test_validate_combinations
    [['point', 'ml'], ['point', 'one_win'], ['ou', 'ml']].each do |ele|
      parlay = parlay_combination_args(ele[0], ele[1])
      place_order(parlay)
      assert_equal false, Order.last.is_valid if ele.include?('one_win')
    end
    assert_equal 0, ::Order.count
  end

  def test_order_betting_amount
    a = parlay_args
    a[:prize] = 1000001
    a[:items] << parlay_item(@match, 'h', 'point', @open)
    a[:items] << parlay_item(@asian, 'h', 'ml', @asian_open)
    place_order(a)
    assert_equal 0, ::Order.count
  end

  def test_prize_exceed_today_limit
    a = parlay_args
    a[:prize] = 500001
    a[:items] << parlay_item(@match, 'h', 'point', @open)
    a[:items] << parlay_item(@asian, 'h', 'ml', @asian_open)
    assert_equal 0, ::Order.count
  end
end
