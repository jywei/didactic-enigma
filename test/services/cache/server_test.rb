require 'test_helper'

class Cache::ServerTest < ActiveSupport::TestCase
  def setup
    @match = create(:match, :with_category, :with_team, :with_book_maker, :with_group)
    create(:offer, :with_category, :with_book_maker, match: @match, h_stake: 250, a_stake: 100, offer_category: @match.category.name)
    @category_id = @match.category_id
    @match.open!
  end

  def test_afu_matches_by
    assert_equal @match.to_open.key, $redis.afu_matches_by([@category_id])[@match.key].key
    assert_equal @match.to_open[:match_number], $redis.afu_matches_by([@category_id])[@match.key][:match_number]
    assert_nil   $redis.afu_matches_by([@category_id])[(@match.id + 1).to_s]
  end

  def test_afu_match
    assert_equal @match.to_open.id, $redis.afu_match(@match.key).id
    assert_equal @match.to_open[:match_number], $redis.afu_match(@match.key)[:match_number]
    assert_nil   $redis.afu_match(@match.id + 1)
    assert_raises(Cache::MatchNotFound) { $redis.afu_match!(@match.id + 1) }
  end

  def test_tx_match
    id       = '12345'
    tx_match = { foo: 'bar' }
    $redis.hset('tx_matches:2000-10-10', id, tx_match.to_json)
    assert_equal tx_match[:foo], $redis.tx_match(id)[:foo]
  end
end
