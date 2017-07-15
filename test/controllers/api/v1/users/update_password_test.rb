require 'test_helper'

class Api::V1::UserControllerUpdatePasswordTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user)
  end

  def test_update_password
    cookies['user'] = @user.access_token
    post "/api/v1/users/update_password", params: { password: "fuck_david" }
    @user.reload
    assert_equal @user.encrypted_password, "fuck_david"
  end
end
