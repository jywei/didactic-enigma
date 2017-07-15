require "test_helper"

class Offer::PositionTest < ActiveSupport::TestCase
  def position
    @position ||= Offer::Position.new
  end

  def setup
    @match = create(:random_match)
    @match.open!
    @redis_match = $redis.afu_match(@match.redis_id)

    @match_three_way = create(:random_match, :with_three_way)
    @match_three_way.open!
    @redis_match_three_way = $redis.afu_match(@match_three_way.redis_id)
  end

  def test_update_position_in_match_model
    @match.update_positions
    assert_equal 0.00,    @match.offer_positions.find_by(offer_name: "ou").h_position
  end

  def test_update_position_logs_match_three_way
    @match_three_way.update_positions
    assert_equal -2_000_000.00, @match_three_way.offer_positions.find_by(offer_name: "three_way").d_threshold
  end

  def test_close_function_unlinking_redis
    @match.close!
    assert_equal nil, $redis.db.hget($matches_key,  @match.key)
    assert_equal nil, $redis.db.hget($matches_ref,  @match.key)
    assert_equal nil, $redis.db.hget($matches_lock, @match.leader_id)
    assert_equal nil, $redis.db.hget($matches_lock, @match.id)
  end

end
