require 'test_helper'

class Api::V1::OrdersControllerHistoryTest < ActionDispatch::IntegrationTest
  def setup
    @user          = create(:user)
    @order         = create(:order, amount: 500, user: @user)
    @order_item    = create(:order_item, order: @order, offer: Offer.first)
    @invalid_order = create(:order, is_valid: false, user: @user)
    @sport         = @order_item.match.category.sport
  end

  def test_history
    cookies['user'] = @user.access_token
    get "/api/v1/orders/history"
    order = JSON.parse(@response.body)['data'].first
    refute_equal 0, JSON.parse(@response.body)['code']
    assert_includes order.keys, "offer_type"
    assert_includes order.keys, "sport"
    assert_includes order.keys, "order_time"
    assert_includes order.keys, "ip"
    assert_includes order.keys, "price"

    assert_includes order.values, @order_item.offer_type
    assert_includes order.values, @sport.name
    assert_includes order.values, @order.ip
  end

  def test_history_without_user
    get "/api/v1/orders/history"
    assert_equal 3, JSON.parse(@response.body)['code']
  end

  def test_history_filter_invalid_order
    cookies['user'] = @user.access_token
    get "/api/v1/orders/history"
    orders = JSON.parse(@response.body)['data']
    id = orders.map { |order| order['id'] }
    refute_includes id, @invalid_order.id
  end

end
