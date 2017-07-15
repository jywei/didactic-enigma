require 'test_helper'

class Api::V1::UsersControllerSettingTest < ActionDispatch::IntegrationTest
  def setup
    db = ActiveRecord::Base.connection
    db.execute(File.read("db/fakers/user_ancestors.sql"))
    db.execute(File.read("db/fakers/user_settings.sql"))
    db.execute(File.read("db/fakers/users.sql"))
    @sport_name = "soccer"
  end

  def log_in(id)
    user = User.find(id)
    cookies['user'] = user.access_token
  end

  # params:{ target_id, table_type, target_column, sport_name, ot_id, adj_amount }
  def get_user_settings(params = nil)
    get "/api/v1/user_settings", params: params
    @info = response.parsed_body
  end

  def update_user_settings(params = nil)
    patch "/api/v1/users/settings", params: params
    @info = response.parsed_body
  end

  def test_self_user_setting
    (43..51).each do |id|
      log_in(id)
      get_user_settings({target_id: id})
      rebate = User::Setting.where(user_id: id, name: @sport_name, ot_id: 1).first.rebate
      value = @info['data']['settings']['soccer']['content']['rebate'][0]['value']
      assert_equal value, rebate
    end
  end

  def test_downline_user_setting
    (43..50).each do |id|
      log_in(id)
      get_user_settings({target_id: id})
      rebate = User::Setting.where(user_id: id + 1, name: @sport_name, ot_id: 1).first.rebate
      value = @info['data']['settings']['soccer']['content']['rebate'][0]['value']
      assert_equal value, rebate
    end
  end

  def test_update_user_setting
    # tier 1~7
    log_in(43)
    update_user_settings({target_id: 44, sport_name: @sport_name, ot_id: 1, target_column: "rebate", adj_amount: 50, table_type: "settings" })
    assert_equal @info['code'],    1
    assert_equal @info['message'], '更新成功'
    (1..7).each do |id|
      oppo = User::Setting.find_by(user_id: (43 + id), name: @sport_name, ot_id: 1)["rebate"]
      assert_equal oppo, 50
    end
  end

  def test_user_setting_failed
    log_in(49)
    get_user_settings()
    assert_equal @info['message'], '使用者ID不可空白'

    get_user_settings({target_id: 0})
    assert_equal @info['message'], '找不到使用者'

    get_user_settings({target_id: 48})
    assert_equal @info['message'], '目標非直屬下限'
  end

  def test_update_user_setting_failed
    log_in(51)
    update_user_settings()

    assert_equal @info['message'], "傳入資訊不可空白"

    update_user_settings({target_id: 0, sport_name: @sport_name, ot_id: 1, target_column: "rebate", adj_amount: 50, table_type: "settings" })
    assert_equal @info['message'], "找不到修改使用者"

    update_user_settings({target_id: 49, sport_name: @sport_name, ot_id: 1, target_column: "rebate", adj_amount: 50, table_type: "settings" })
    assert_equal @info['message'], "玩家無權限"

    log_in(48)
    update_user_settings({target_id: 49, sport_name: @sport_name, ot_id: 1, target_column: "rebate", adj_amount: 101, table_type: "settings" })
    assert_equal @info['message'], "設定值不可小於自身原值或資料錯誤"
  end
end
