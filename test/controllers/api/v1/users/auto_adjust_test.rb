require 'test_helper'

class Api::V1::UsersControllerAutoAdjustTest < ActionDispatch::IntegrationTest
  def setup
    db = ActiveRecord::Base.connection
    db.execute(File.read("db/fakers/user_ancestors.sql"))
    db.execute(File.read("db/fakers/user_allotters.sql"))
    db.execute(File.read("db/fakers/user_settings.sql"))
    db.execute(File.read("db/fakers/users.sql"))
    @sport             = "soccer"
    @ot_id             = 1
    @user_id           = 45
    @target_id         = 46
    @adjust_parameter = 0.1
    @auto_params = {
      sport_name:     @sport,
      target_id:      @target_id,
      adj_amount:     @adjust_parameter,
      target_column:  "rebate",
      ot_id:          @ot_id,
      table_type:     "settings"
    }
    log_in(@user_id)
  end

  def log_in(id)
    user = User.find(id)
    cookies['user'] = user.access_token
  end

  def test_validation_auto_adjust
    post '/api/v1/users/validation_auto_adjust', params: @auto_params
    @info = response.parsed_body
    assert_equal      @info['message'], "5"
  end

  def test_return_all_rebate
    post '/api/v1/user_settings/return_all_rebate', params: @auto_params
    self_setting    = User::Setting.find_by(user_id: @user_id, name: @sport, ot_id: @ot_id)
    target_setting  = User::Setting.find_by(user_id: @target_id, name: @sport, ot_id: @ot_id)
    assert_equal    self_setting.rebate, target_setting.rebate
  end

  def test_return_none_rebate
    post '/api/v1/user_settings/return_none_rebate', params: @auto_params
    target_setting  = User::Setting.find_by(user_id: @target_id, name: @sport, ot_id: @ot_id)
    assert_equal    0, target_setting.rebate
  end

end
