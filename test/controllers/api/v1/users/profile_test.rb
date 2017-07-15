require 'test_helper'

class Api::V1::UsersProfileControllerTest < ActionDispatch::IntegrationTest
  def setup
    db = ActiveRecord::Base.connection
    db.execute(File.read("db/fakers/users.sql"))
    db.execute(File.read("db/fakers/user_ancestors.sql"))
    @current_user = User.find(49)
    @user = create(:user)
    @user_profile = create(:user_profile, user_id: @user.id)
    # create fake user_ancestor which member & user_id are same
    @user_ancestor = create(:user_ancestor, user_id: @user.id, general_agent: @current_user.id, member: @user.id)
  end

  def patch_profile(params)
    cookies['user'] = @current_user.access_token
    patch "/api/v1/users/profiles", params: params
    @info = response.parsed_body
  end

  def show_profile(params)
    cookies['user'] = @current_user.access_token
    get "/api/v1/users/profiles", params: params
    @info = response.parsed_body
  end

  def test_update_other_downline
    params = {
      user_profile: {
        target_id:      9453
      }
    }
    patch_profile(params)
    assert_equal                        0, @info['code']
    assert_equal              "請確認權限" , @info['message']
  end

  def test_update_over_delay
    params = {
      user_profile: {
        delay_original: 5,
        delay_running:  4,
        target_id:      @user.id
      }
    }
    patch_profile(params)
    assert_equal                        0, @info['code']
    assert_equal          "延遲秒數設定錯誤", @info['message']
  end

  def test_update_over_parlay
    params = {
      user_profile: {
        parlay:         11,
        target_id:      @user.id
      }
    }
    patch_profile(params)
    assert_equal                        0, @info['code']
    assert_equal             "串關上限錯誤", @info['message']
  end

  def test_update_success
    params = {
      user_profile: {
        parlay:             9,
        delay_original:     1,
        delay_running:      1,
        target_id:          @user.id
      }
    }
    patch_profile(params)
    profile = User::Profile.find_by(user_id: @user.id)
    assert_equal          1, @info['code']
    assert_equal          1, profile.delay_original
    refute_equal          0, profile.delay_original

    assert_equal          1, profile.delay_running
    refute_equal          0, profile.delay_running

    assert_equal          9, profile.parlay
    refute_equal         10, profile.parlay
  end

  def test_show_profile
    # success
    params = { target_id: @user.id }

    show_profile(params)
    assert_equal          1, @info['code']
    assert_equal          2, @info['data'].length
    refute_equal          "", @info['data']['user']
    #fail
    params = { target_id: 9453 }

    show_profile(params)
    assert_equal          0, @info['code']
    assert_equal          0, @info['data'].length
  end

end
