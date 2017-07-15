require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    create(:user, :admin)
    @admin = User.first.class_to_admin
    @user  = create(:user)
    create(:user_profile, user_id: @user.id)
  end

  def test_normal_user_info
    info = @user.info
    refute_nil   info[:tier]
    refute_nil   info[:quota]
    assert_equal 10, info[:parlay_limit]
    assert_nil   info[:is_admin]
  end

  def test_admin_info
    info = @admin.info
    refute_nil   info[:is_admin]
    assert_nil   info[:tier]
    assert_nil   info[:quota]
  end
end
