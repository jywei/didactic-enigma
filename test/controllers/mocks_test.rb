require 'test_helper'

class MocksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @sport           = create(:sport, :baseball)
    @category        = create(:category, :mlb)
    @hteam           = create(:team, name: 'foobar', category: @category)
    @ateam           = create(:team, name: 'kkk', category: @category)
    @match_active    = create(:match, :with_group, :with_book_maker, :with_offers, hteam: @hteam, ateam: @ateam, category: @category, active: true)
    @match_active.open!
  end

  def redis_match
    @m ||= $redis.afu_match(@match_active.key)
  end

  def test_results
    get "/results"
    assert_includes @response.body, @hteam.name
    assert_includes @response.body, @ateam.name
  end

  def test_results_submit
    get "/results_submit", params: { h_score: 15, a_score: 13, leader_id: @match_active.leader_id }
    assert_includes @response.body, "success"
    assert_nil      redis_match
    assert_equal    @match_active.reload.h_score, 15
  end
end

