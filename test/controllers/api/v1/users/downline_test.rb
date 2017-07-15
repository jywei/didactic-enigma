require 'test_helper'

class Api::V1::UsersControllerDownlineTest < ActionDispatch::IntegrationTest
  def setup
    db = ActiveRecord::Base.connection
    db.execute(File.read("db/fakers/user_ancestors.sql"))
    db.execute(File.read("db/fakers/user_allotters.sql"))
    db.execute(File.read("db/fakers/users.sql"))
    db.execute(File.read("db/fakers/user_profiles.sql"))
  end

  def log_in(id)
    @user = User.find(id)
    cookies['user'] = @user.access_token
  end

  def get_downline_profile(params)
    get '/api/v1/users/downline_profile', params: params
    @info = response.parsed_body['data']['downlines']
  end

  def get_downline_list(params)
    get "/api/v1/users/downline_list", params: params
    @info = response.parsed_body
  end

  def test_downline_profile
    log_in(43)
    get_downline_profile({ target_id: 43 })
    downline = User.find(44)
    profile  = User::Profile.find_by(user_id: 44)
    allotter = User::Allotter.find_by(user_id: 44, name: "soccer")
    assert_equal @info['users'][0]['id'],                     downline.id
    assert_equal @info['profiles'][0]['nickname'],            profile.nickname
    assert_equal @info['profiles'][0]['user_id'],             downline.id
    assert_equal @info['profiles'][0]['current_quota'].to_f,  downline.remaining_quota_today / 10_000
    assert_equal @info['allotters'][0]['user_id'],            downline.id
    assert_equal @info['allotters'][0]['oppo'].to_f,          allotter.oppo
    assert_equal @info['else'][0]['downline_count'],          downline.all_downlines.size
  end

  def test_downline_user_allotter
    log_in(43)
    (1..8).each do |tier|
      get_downline_list({tier: tier})
      assert_equal @info['code'], 1
      assert_equal @info['data']['downline_list'].length, 1
    end
  end
end
