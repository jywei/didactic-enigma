require 'test_helper'

class Api::V1::OrdersControllerRecentTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user)
    @order = create(:order, id: 3, amount: 500, user: @user)
    @parlay = create(:order, :with_parlay, id: 4, amount: 500, user: @user)
    @hteam = @order.item.match.hteam
    @ateam = @order.item.match.ateam
  end

  def get_orders
    cookies['user'] = @user.access_token
    get "/api/v1/player/orders/recent"
    @orders = JSON.parse(@response.body)['data']
  end

  def test_recent_order
    get_orders
    order = @orders.first
    assert_includes order.keys, "id"
    assert_includes order.keys, "items"
    assert_includes order.keys, "order_at"
  end

  def test_recent_order_items_standard
    get_orders
    order = @orders.select{|o| o['id'] == 3 }.first

    item = order['items'].first
    assert_includes item.values, @order.items.first.odd.to_f
    assert_includes item.values, @hteam.display_name
    assert_includes item.values, @ateam.display_name
  end

  def test_recent_order_items_parlay
    get_orders
    order = @orders.select{|o| o['id'] == 4 }.first

    items = order['items']
    assert_operator items.size, :>, 1
  end

end
