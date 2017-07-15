require 'test_helper'

class Match::Open::BuilderTest < ActiveSupport::TestCase
  def setup
    @match_a = create(:random_match)
    @match_b = create(:random_match)
    # @match.open!
    # @redis_match = $redis.afu_match(@match.redis_id)
    Category.save_current
    Match.open!
  end

  def redis_match_a
    @redis_match_a ||= $redis.afu_match!(@match_a.key) 
  end
  
  def test_halves_group
    assert_includes redis_match_a.keys, 'halves_match_id'
    assert_equal    @match_a.match_id, redis_match_a[:halves_match_id]
  end
end
