require 'test_helper'

class Api::V1::Player::BalancesControllerTest < ActionDispatch::IntegrationTest
  def setup
    last_week       = Time.now.last_week
    last_monday     = last_week.monday
    previous_monday = last_week.last_week.monday
    @user                = create(:user)
    @old_order           = create(:order, amount: 500, user: @user)
    @order               = create(:order, amount: 500, user: @user, created_at: Time.now.monday)
    @last_week_order1    = create(:order, amount: 600, user: @user, created_at: last_monday)
    @last_week_order2    = create(:order, amount: 700, user: @user, created_at: last_monday + 1.day)
    @two_weeks_ago_order = create(:order, amount: 800, user: @user, created_at: previous_monday)
    @invalid_order       = create(:order, amount: 500, user: @user, created_at: previous_monday, is_valid: false)
  end

  def balances
    @balances ||= JSON.parse(@response.body)
  end

  def set_cookies
    cookies['user'] = @user.access_token
  end

  def set_parlay_order
    @parlay_order = create(:order, :with_parlay, user: @user, created_at: Time.now.monday)
    @parlay_order.items.second.update_attributes(sport_id: "75")
    @parlay_order.items.third.update_attributes(sport_id: "76")
  end

  def amount_from_monday
    balances[0][-2]['amount']
  end

  def test_weekly_balances
    set_cookies
    get "/api/v1/player/balances/weekly"
    last_week_total_amount = @last_week_order1.amount + @last_week_order2.amount
    assert_equal @order.amount,               amount_from_monday
    assert_equal @last_week_order1.amount,    balances[1][-2]['amount']
    assert_equal @two_weeks_ago_order.amount, balances[2][-1]['amount']
    assert_equal last_week_total_amount,      balances[1][-1]['amount']
  end

  def test_query_success_with_sport_id
    set_cookies
    get "/api/v1/player/balances/weekly", params: { sport_id: "77" }
    assert_equal @order.amount, amount_from_monday
  end

  def test_query_failed_with_sport_id
    set_cookies
    get "/api/v1/player/balances/weekly", params: { sport_id: "78" }
    assert_equal 0, amount_from_monday
  end

  def test_query_success_with_type_id
    @running_order = create(:order, amount: 500, type_flag: "running", user: @user, created_at: Time.now.monday)
    @running_order.item.update_attributes(offer_name: "point")
    @order.item.update_attributes(offer_name: "point")
    set_cookies
    get "/api/v1/player/balances/weekly", params: { type_id: "1,3" }
    assert_equal @order.amount, amount_from_monday
  end

  def test_query_failed_with_type_id
    @order.item.update_attributes(offer_name: "point")
    set_cookies
    get "/api/v1/player/balances/weekly", params: { type_id: "4" }
    assert_equal 0, amount_from_monday
  end

  def test_query_parlay_success
    set_parlay_order
    set_cookies
    get "/api/v1/player/balances/weekly", params: { sport_id: "75,76,77" , type_id: "13" }
    assert_equal @parlay_order.amount, amount_from_monday
  end

  def test_query_parlay_failed
    set_parlay_order
    set_cookies
    get "/api/v1/player/balances/weekly", params: { sport_id: "75,76", type_id: "13" }
    assert_equal 0, amount_from_monday
  end
end
