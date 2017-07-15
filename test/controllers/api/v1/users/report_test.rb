require 'test_helper'

class Api::V1::UsersControllerReportTest < ActionDispatch::IntegrationTest
  def setup
    db = ActiveRecord::Base.connection
    db.execute(File.read("db/fakers/user_report.sql"))
    db.execute(File.read("db/fakers/orders.sql"))
    db.execute(File.read("db/fakers/order_ancestors.sql"))
    db.execute(File.read("db/fakers/user_ancestors.sql"))
    db.execute(File.read("db/fakers/order_items.sql"))
    %i(soccer ice_hockey basketball rugby_union tennis us_football baseball volleyball).each do |name|
      create(:sport, name)
    end
  end

  def log_in_with_id(id)
    @user = User.find(id)
    cookies['user'] = @user.access_token
  end

  def get_user_report(id, confirm_id = nil, params = nil)
    if params
      get "/api/v1/users/#{id}/reports", params: params
    elsif confirm_id
      get "/api/v1/users/#{confirm_id}/reports"
    else
      get "/api/v1/users/#{id}/reports"
    end
    @info = response.parsed_body
  end

  def set_params
    params = {}
    params[:sport_id]   = "75,76,77,78,79"
    params[:type_id]    = "1,2,3,4,5"
    params[:start_date] = "2017-01-10T18:15:30.198Z"
    params[:end_date]   = "2017-01-13T18:15:30.198Z"
    params
  end

  def test_send_status
    log_in_with_id(156)
    get_user_report(156)
    assert_equal response.status, 200
  end

  def test_info_accuracy
    # tier 1~6層
    (156..161).each do |id|
      log_in_with_id(id)
      get_user_report(id)
      @info = @info['data']['report']
      assert_equal @info['name'].length, @user.downline_names(:en).length
      total = @info['total']
      total.length.times.each do |i|
        orders = Order.where(user_id: @user.downlines[i].downline_user_ids, vigorish_split: true)
        valid_amount = orders.map(&:valid_amount).sum
        amount       = orders.map(&:amount).sum
        assert_includes @user.downlines.pluck(:id), total[0]['id']
        assert_equal total[i]['valid_amount'],      valid_amount
        assert_equal total[i]['amount'],            amount
      end
    end
    # tier 7
    log_in_with_id(162)
    get_user_report(162)
    @info = @info['data']['report']
    assert_equal @info['name'].length,                @user.downline_names(:en).length
    assert_equal @info['total'].length,               4
    # tier 8
    log_in_with_id(163)
    get_user_report(163)
    assert_equal @info['data'].length,                        0
  end

  def test_user_not_in_same_ancestor
    log_in_with_id(156)
    get_user_report(156, 167)
    assert_equal @info["data"].length,                        0
  end

  def test_filter
    log_in_with_id(156)
    orders = Order.where(user_id: @user.downline_user_ids)
    params = set_params
    get_user_report(156, nil, params)
    @info = @info['data']['report']
    orders_count = calculate_order_count(params, orders)
    assert_equal @info['name'].length,              @user.downline_names(:en).length
    assert_equal @info['total'][0]['orders_count'], orders_count
  end

  def test_filter_with_sport_id
    log_in_with_id(156)
    orders = Order.where(user_id: @user.downline_user_ids)
    params = set_params
    params[:sport_id] = '75'
    get_user_report(156, nil, params)
    @info = @info['data']['report']
    orders_count = calculate_order_count(params, orders)
    assert_equal @info['total'][0]['orders_count'], orders_count
  end

  def test_filter_with_type_id
    log_in_with_id(156)
    orders = Order.where(user_id: @user.downline_user_ids)
    params = set_params
    params[:type_id] = '3'
    get_user_report(156, nil, params)
    @info = @info['data']['report']
    orders_count = calculate_order_count(params, orders)
    assert_equal @info['total'][0]['orders_count'], orders_count
  end

  def test_filter_with_time
    log_in_with_id(156)
    orders = Order.where(user_id: @user.downline_user_ids)
    params = set_params
    params[:start_date] = "2016-01-10T18:15:30.198Z"
    params[:end_date] = "2016-01-13T18:15:30.198Z"
    get_user_report(156, nil, params)
    @info = @info['data']['report']
    orders_count = calculate_order_count(params, orders)
    assert_equal @info['total'][0]['orders_count'], orders_count
  end

  def calculate_order_count(params, orders)
    sport_ids = params[:sport_id].split(",")
    type_ids  = params[:type_id].split(",")
    time      = Time.parse(params[:start_date])..Time.parse(params[:end_date])
    select_orders = orders.select do |order|
      (order.item.sport_id.to_s.in? sport_ids) &&
      (["normal", order.item.offer_name].in? order.offer_names(type_ids)) &&
      (order.created_at.to_date.in? time) &&
      (order.user_id.in? @user.downlines.first.downline_user_ids) &&
      order.vigorish_split == true
    end
    select_orders.count
  end

end
