require 'test_helper'

class AutoAdjustTest < ActiveSupport::TestCase
  def setup
    db = ActiveRecord::Base.connection
    db.execute(File.read("db/fakers/user_ancestors.sql"))
    db.execute(File.read("db/fakers/user_allotters.sql"))
    db.execute(File.read("db/fakers/user_settings.sql"))
    db.execute(File.read("db/fakers/users.sql"))
    @sport             = "soccer"
    @ot_id             = 1
  end

  def test_auto_adjust_allotters
    adjust_parameter = 0.1
    params = {
      sport_name:     @sport,
      target_id:      46,
      adj_amount:     adjust_parameter,
      target_column:  "oppo",
      ot_id:          @ot_id,
      table_type:     "allotters"
    }
    AutoAdjust.new(params).adjust
    (47..50).each { |id|
      assert_equal adjust_parameter, User::Allotter.find_by(name: @sport, user_id: id).oppo.to_f
    }
  end

  def test_auto_adjust_settings
    adjust_parameter = 99
    params = {
      sport_name:     @sport,
      target_id:      46,
      adj_amount:     adjust_parameter,
      target_column:  "rebate",
      ot_id:          @ot_id,
      table_type:     "settings"
    }
    AutoAdjust.new(params).adjust
    (47..51).each { |id|
      assert_equal adjust_parameter, User::Setting.find_by(name: @sport, user_id: id).rebate.to_f
    }
  end
end
