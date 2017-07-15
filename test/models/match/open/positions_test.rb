require 'test_helper'

class Match::Open::PositionsTest < ActiveSupport::TestCase
  def setup
    @match = create(:random_match)
    @match.open!
    @redis_match = $redis.afu_match(@match.redis_id)
  end

  def hash1(team = 'h', offer = 'ml')
    {
      match_id: @redis_match.key,
      team: team,
      offer: offer,
      odd: 0.95,
      amount: 20_000_000,
      prize: 19_000_000,
      rate_mode: 'default'
    }
  end

  def hash2(team = 'h', offer = 'ml')
    {
      match_id: @redis_match.key,
      team: team,
      offer: offer,
      odd: 0.95,
      amount: 10_000_000,
      prize: 9_500_000,
      rate_mode: 'default'
    }
  end

  def hash3(team = 'h', offer = 'ml')
    {
      match_id: @redis_match.key,
      team: team,
      offer: 'ml',
      threshold: 3_000_000
    }
  end

  def test_adjust_position_from_orders_positions_and_distance
    @redis_match.adjust_position_from_orders!(hash1)
    assert_equal -19_000_000,   @redis_match.ml[:positions][:h]
    assert_equal 20_000_000,    @redis_match.ml[:positions][:a]
    assert_equal 950.0,         @redis_match.ml[:distances][:h]
    assert_equal -1000.0,       @redis_match.ml[:distances][:a]
  end

  def test_adjust_position_from_orders_loop_2_times_for_positions_and_distance
    @redis_match.adjust_position_from_orders!(hash1)
    assert_equal -19_000_000,   @redis_match.ml[:positions][:h]
    assert_equal 950.0,         @redis_match.ml[:distances][:h]

    @redis_match.adjust_position_from_orders!(hash1)
    assert_equal 40_000_000,    @redis_match.ml[:positions][:a]
    assert_equal -2000.0,       @redis_match.ml[:distances][:a]
  end

  def test_adjust_position_from_orders_with_different_input
    @redis_match.adjust_position_from_orders!(hash2('a', 'ml'))
    assert_equal 475.0,         @redis_match.ml[:distances][:a]
  end

  def test_adjust_position_from_orders_and_threshold
    @redis_match.adjust_position_from_orders!(hash1)
    assert_equal -19_000_000,   @redis_match.ml[:positions][:h]
    assert_equal 950.0,         @redis_match.ml[:distances][:h]

    @redis_match.adjust_position_from_thresholds!(hash3)
    assert_equal -19_000_000,   @redis_match.ml[:positions][:h]
    assert_equal 833.3,         @redis_match.ml[:distances][:h]
  end
end
