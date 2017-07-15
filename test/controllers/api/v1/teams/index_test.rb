require 'test_helper'

class Api::V1::TeamsControllerIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = create(:user, :admin, :with_admin_roles)
    @team  = create(:team, category_id: 300)
    @team2 = create(:team, category_id: 400)
  end

  def test_index
    cookies['user'] = @admin.access_token
    get "/api/v1/teams/", params: {category_id: 400}
    teams = response.parsed_body['data']['teams']
    team = teams.first
    assert_includes team.keys, "id"
    assert_includes team.keys, "name"
    assert_includes team.keys, "display_name"
    assert_includes team.values, @team2.id
    assert_includes team.values, @team2.name
    assert_includes team.values, @team2.name_cn

    get "/api/v1/teams/", params: {search: @team.name_cn.slice(0..2)}
    teams = response.parsed_body['data']['teams']
    team = teams.first
    assert_includes team.values, @team.id
    assert_includes team.values, @team.name
    assert_includes team.values, @team.name_cn
  end

  def test_index_without_user
    get "/api/v1/teams/", params: {category_id: 300}
    assert_equal 0, response.parsed_body['code']
    assert_equal '使用者未登入', response.parsed_body['message']
  end

  def test_update_teams
    cookies['user'] = @admin.access_token
    updated_name = "test"
    patch "/api/v1/teams/#{@team.id}", params: {name: updated_name}
    assert_equal 1, response.parsed_body['code']
    assert_equal updated_name, @team.reload.name_cn

    updated_name = ""
    patch "/api/v1/teams/#{@team.id}", params: {name: updated_name}
    assert_equal 2, response.parsed_body['code']
    assert_equal '傳入資訊不可空白', response.parsed_body['message']
  end

end
