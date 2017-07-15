require 'test_helper'

class Api::V1::PositionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @sport          = create(:sport, :baseball)
    @category       = create(:category, :mlb)
    @match          = create(:match, :with_team, :with_book_maker, :with_offers, :with_group, category: @category)
    @match.open!
    @redis_match    = $redis.afu_match(@match.redis_id)
    @user         ||= create(:user)
    @admin        ||= create(:user, :admin)
  end

  def match
    @m            ||= JSON.parse(@response.body)['matches'][@match.key]
  end

  def offers
    match['play']
  end

  def params
    {
      sport_id:           @sport.id,
      match_id:           @match.id,
      category_id:        @category.id,
      created_start_date: '',
      created_end_date:   '',
      match_start_date:   '',
      match_end_date:     ''
    }
  end

  def threshold_adjust(team = 'h', offer = 'ml')
    {
      match_id:    @redis_match.key,
      team:        team,
      offer:       offer,
      threshold:   300.0,
      user_id:     @user.id
    }
  end

  def create_warning
    @redis_match.adjust_position_from_thresholds!(threshold_adjust)
    @warning_offer = @redis_match[:play][threshold_adjust[:offer]]
    @warning_offer.update_position_to_log_from(threshold_adjust)
  end

  def test_index
    get "/api/v1/positions", params: { sport_id: @sport.leader_spid }
    assert match
    assert_includes match.keys, 'match_id'
    assert_includes match.keys, 'h_stake'
    assert_includes match.keys, 'a_stake'
    assert_includes match.keys, 'team'

    assert_includes offers.keys, 'point'
    assert_includes offers.keys, 'ou'
    assert_includes offers.keys, 'one_win'
    assert_includes offers.keys, 'odd_even'

    assert_includes offers['point'].keys, 'h_stake'
    assert_includes offers['point'].keys, 'a_stake'
  end

  def test_warning_log
    create_warning
    cookies['user'] = @admin.access_token
    get "/api/v1/positions/warning_log", params: params
    query_result = JSON.parse(@response.body)["data"]["warning_log"]

    assert_equal threshold_adjust[:threshold], query_result[0]["h_threshold"].to_f
  end
end

