require 'test_helper'

class Api::V1::GroupsControllerIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user  = create(:user)
    @group = create(:group, :with_category)
  end

  def test_index
    cookies['user'] = @user.access_token
    get "/api/v1/groups/", params: { search: @group.display_name }
    groups = response.parsed_body['data']
    group  = groups.first
    assert_includes group.keys, "id"
    assert_includes group.keys, "name"
    assert_includes group.keys, "display_name"
    assert_includes group.values, @group.id
    assert_includes group.values, @group.tx_name
    assert_includes group.values, @group.display_name
  end

  def test_index_without_user
    get "/api/v1/groups/"
    assert_equal 0, response.parsed_body['code']
    assert_equal 'User not logged in.', response.parsed_body['data']
  end

  def test_update_groups
    updated_name = "test"
    patch "/api/v1/groups/#{@group.id}", params: { name: updated_name }
    assert_equal 1, response.parsed_body['code']
    assert_equal updated_name, @group.reload.display_name

    updated_name = ""
    patch "/api/v1/groups/#{@group.id}", params: { name: updated_name }
    assert_equal 0, response.parsed_body['code']
    assert_equal '傳入資訊不可空白', response.parsed_body['message']
  end
end
