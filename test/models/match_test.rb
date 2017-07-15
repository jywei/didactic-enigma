require 'test_helper'

class MatchTest < ActiveSupport::TestCase
  def setup
    @match = create(:match, :with_category, :with_team, :with_book_maker, :with_group)
    create(:offer, :with_category, :with_book_maker, match: @match, head: 4, h_stake: 250, a_stake: 100, offer_category: @match.category.name)
    create(:offer, :with_category, :with_book_maker, match: @match, head: 5, h_stake: 250, a_stake: 100, offer_category: @match.category.name)
    @match_b = create(:match, :with_category, :with_team, :with_book_maker, :with_group, halves: 'full')
  end

  def test_h_stake
    assert_equal 500, @match.reload.h_stake
  end

  def test_a_stake
    assert_equal 200, @match.reload.a_stake
  end

  def test_close!
    match = create(:match, :with_category, :with_team, :with_book_maker, :with_offers, :with_group, start_time: Time.now - 5.days)
    match.open!
    match.close!
    assert_equal false, match.active
  end

  def test_all_open!
    Match.open!
    match = $redis.afu_matches[@match.key]
    assert_equal nil, match[:match_result]

    match[:match_result] = 'ddos'
    match.save!
    match = $redis.afu_matches[@match.key]
    assert_equal 'ddos', match[:match_result]
  end

  def test_collect_leader_offers_no_exception
    assert_nothing_raised { @match_b.collect_leader_offers(nil, Log::Push::Temp.new) }
    assert @match_b.offers.empty?
  end

  def test_collect_leader_offers
    t = Time.now.strftime('%Y-%m-%d')
    $redis.hset("tx_matches:#{t}", @match_b.leader_id, {
      hteam_id:   @match_b.hteam.tx_id,
      ateam_id:   @match_b.ateam.tx_id,
      start_time: (Time.now + 1.day).utc.strftime('%Y-%m-%d %H:%M:%S UTC'),
      hteam:      @match_b.hteam.name,
      ateam:      @match_b.ateam.name,
      mgid:       @match_b.category.mgid,
      offer_id:   %w(g1 g2 g3 g4 g5)
    }.to_json)
    ofs_hash = {
      match_id: @match_b.leader_id,
      bid: 83
    }
    $redis.hset("tx_offers:#{t}", 'g1', ofs_hash.merge(
      h_oppo: 0.51,
      ot_id: 59,
      head: 1.5
    ).to_json)
    $redis.hset("tx_offers:#{t}", 'g2', ofs_hash.merge(
      h_oppo: 0.49,
      ot_id: 20,
      head: 0.0
    ).to_json)

    @match_b.collect_leader_offers(nil, Log::Push::Temp.new)
    assert_includes @match_b.offers.pluck(:leader_id), 'g1'
    refute_includes @match_b.offers.pluck(:leader_id), 'g2'
  end

  def test_parlay_exist_in_redis
    match_a = @match.open!
    match_b = $redis.afu_match(match_a.key)
    assert match_a[:parlay]
    assert_equal match_a[:parlay], match_b[:parlay]
  end
end
