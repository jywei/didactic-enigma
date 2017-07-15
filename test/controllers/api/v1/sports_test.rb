require 'test_helper'

class Api::V1::SportsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin          = create(:user, :admin)
    @sport_active   = create(:sport, :baseball)
    @sport_inactive = create(:sport, :basketball, active: false)
  end

  def test_index
    get "/api/v1/sports"
    assert_includes response.body, @sport_active.display_name
    refute_includes response.body, @sport_inactive.display_name
  end

  def test_update
    cookies['user'] = @admin.access_token
    assert_equal Cache::Category.selected[0][:name], @sport_active.display_name

    patch "/api/v1/sports/#{@sport_active.leader_spid}", params: { name: 'aniki' }
    get '/api/v1/sports'

    assert_equal @sport_active.reload.display_name, 'aniki'
    assert_equal response.parsed_body[0]['name'], 'aniki'

    get "/api/v1/categories"

    assert_equal response.parsed_body['selected'][0]['name'], 'aniki'
  end
end

