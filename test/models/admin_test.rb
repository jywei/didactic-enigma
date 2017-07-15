require 'test_helper'

class AdminTest < ActiveSupport::TestCase
  def setup
    create(:user, :admin)
    @role  = create(:role, controller: "fuck_david", action: "aniki")
    @admin = User.first.class_to_admin
  end

  def test_add_and_remove_role
    refute_includes @admin.roles, @role
    @admin.add_role(@role.id)
    assert_includes @admin.roles, @role
    @admin.remove_role(@role.id)
    refute_includes @admin.roles, @role
  end
end
