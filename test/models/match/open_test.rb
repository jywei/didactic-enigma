require 'test_helper'

class Match::OpenTest < ActiveSupport::TestCase
  def setup
    @match               = create(:match, :full, :with_offers,            :with_team, :with_category, :with_book_maker, :with_group)
    @series_off_match    = create(:match, :full, :with_offers_series_off, :with_team, :with_category, :with_book_maker, :with_group)
    @soccer              = create(:match, :ht,   :with_offers,            :with_team, :with_category, :with_book_maker, :with_group, match_category: :fifa)
    @baseball            = create(:match, :ht,   :with_offers,            :with_team, :with_category, :with_book_maker, :with_group, :with_asian_offers, match_category: :mlb)
    @series_off_baseball = create(:match, :ht,   :with_offers_series_off, :with_team, :with_category, :with_book_maker, :with_group, match_category: :mlb)
    @open                     = @match.open!
    @series_off_open          = @series_off_match.open!
    @soccer_open              = @soccer.open!
    @baseball_open            = @baseball.open!
    @series_off_baseball_open = @series_off_baseball.open!
    @series_modifier          = 50
  end

  def afu_match
    $redis.afu_match(@open.key)
  end

  def args(match_id, type = 'h', offer = "ml", modifier = 50, last_updated = nil, user_id = 1)
    {
      'match_id'     => match_id,
      'type'         => type,
      'offer'        => offer,
      'modifier'     => modifier,
      'last_updated' => last_updated,
      'user_id'      => user_id
    }
  end

  def test_update_odd_success
    modifier  = 0.88533
    timestamp = DateTime.mil(10)
    @open.update_odd! args(@match.redis_id, 'h', 'ml', modifier, timestamp)
    assert_equal modifier, @open[:play][:ml][:h_modifier]
  end

  def test_update_odd_different_user_success
    modifier  = 0.88533
    timestamp = DateTime.mil(10)
    @open.update_odd! args(@match.redis_id, 'h', 'ml', modifier, timestamp)
    modifier  = 0.77222
    timestamp = DateTime.mil(-10)
    @open.update_odd! args(@match.redis_id, 'h', 'ml', modifier, timestamp, 2)
    assert_equal modifier, @open[:play][:ml][:h_modifier]
  end

  def test_update_asian_odd!
    modifier  = 50
    timestamp = DateTime.mil(10)
    @baseball_open.update_odd! args(@baseball.redis_id, 'asian', 'point', modifier, timestamp)
    # assert_equal modifier, @open[:play][$offer_index[:ml]][:handicapped][:modifier]
    assert_equal modifier, @baseball_open[:play][:point][:handicapped][:modifier]
  end

  def test_udpate_odd_when_series_off
    old_parlay_modifier = @series_off_open[:parlay][:ml][:h_modifier]
    @series_off_open.update_odd! args(@series_off_match.redis_id)
    assert_equal @series_modifier, @series_off_open[:play][:ml][:h_modifier]
    assert_equal old_parlay_modifier, @series_off_match.offers.find_by(name: "ml").parlay.h_modifier.to_f
  end

  def test_update_odd_when_series_on
    @open.update_odd! args(@match.redis_id)
    assert_equal @series_modifier, @open[:play][:ml][:h_modifier]
    assert_equal @series_modifier, @match.offers.find_by(name: "ml").parlay.h_modifier.to_f
  end

  def test_update_asian_odd_when_series_off
    old_parlay_modifier = @series_off_baseball_open[:parlay][:ml][:h_modifier]
    @series_off_baseball_open.update_odd! args(@series_off_baseball.redis_id)
    assert_equal @series_modifier, @series_off_baseball_open[:play][:ml][:h_modifier]
    assert_equal old_parlay_modifier, @series_off_baseball.offers.find_by(name: "ml").parlay.h_modifier.to_f
  end

  def test_update_asian_odd_when_series_on
    @baseball_open.update_odd! args(@baseball.redis_id)
    assert_equal @series_modifier, @baseball_open[:play][:ml][:h_modifier]
    assert_equal @series_modifier, @baseball.offers.find_by(name: "ml").parlay.h_modifier.to_f
  end

  def test_update_asian_proportion_when_series_off
    old_parlay_modifier = @series_off_baseball_open[:parlay][:ml][:handicapped][:modifier]
    @series_off_baseball_open.update_odd! args(@series_off_baseball.redis_id, 'asian')
    assert_equal @series_modifier, @series_off_baseball_open[:play][:ml][:handicapped][:modifier]
    assert_equal old_parlay_modifier, @series_off_baseball.offers.find_by(name: "ml").parlay.h_modifier.to_f
  end

  def test_update_asian_proportion_when_series_on
    @baseball_open.update_odd! args(@baseball.redis_id, 'asian', 'point')
    assert_equal @series_modifier, @baseball_open[:play][:point][:handicapped][:modifier]
    assert_equal @series_modifier, @baseball.offers.find_by(name: "point").parlay.asian_modifier.to_f
  end

  def test_save!
    match_number         = '新的match_number'
    @open[:match_number] = match_number
    @open.save!
    assert_equal match_number, afu_match[:match_number]
  end

  def test_pause_one!
    @open.change_stat!('offer' => 'point', 'stat' => 'paused')
    assert_equal 'paused', afu_match[:play][:point][:stat]
    assert_equal 'paused', Offer.find(afu_match[:play][:point][:offer_id]).stat
  end

  def test_pause_one_parlay!
    @open.change_stat!('offer' => 'point', 'stat' => 'paused')
    assert_equal 'paused', afu_match[:parlay][:point][:stat]
    assert_equal 'paused', Offer::Parlay.find(afu_match[:parlay][:point][:parlay_id]).stat
  end

  def test_pause_all_parlay!
    @open.change_stat!('offer' => 'all', 'stat' => 'paused')
    assert_equal 'paused', afu_match[:stat]
    assert_equal 'paused', Offer::Parlay.find(afu_match[:parlay][:point][:parlay_id]).stat
  end

  def test_pause_all!
    @open.change_stat!('offer' => 'all', 'stat' => 'paused')
    assert_equal 'paused', afu_match[:stat]
    assert_equal 'paused', afu_match.db_match.reload.stat
    assert_equal 'paused', afu_match.db_match.reload.offers.first.stat
  end

  def test_resume_one!
    @open.change_stat!('offer' => 'point', 'stat' => 'normal')
    assert_equal 'normal', afu_match[:play][:point][:stat]
    assert_equal 'normal', Offer.find(afu_match[:play][:point][:offer_id]).stat
  end

  def test_resume_all!
    @open.change_stat!('offer' => 'all', 'stat' => 'normal')
    assert_equal 'normal', afu_match[:stat]
    assert_equal 'normal', afu_match.db_match.reload.stat
    assert_equal 'normal', afu_match.db_match.reload.offers.last.stat
  end

  def test_disable_one!
    @open.change_stat!('offer' => 'ou', 'stat' => 'disabled')
    assert_equal 'disabled', afu_match[:play][:ou][:stat]
    assert_equal 'disabled', Offer.find(afu_match[:play][:ou][:offer_id]).stat
  end

  def test_disable_all!
    @open.change_stat!('offer' => 'all', 'stat' => 'disabled')
    assert_equal 'disabled', afu_match[:stat]
    assert_equal 'disabled', afu_match.db_match.reload.stat
    assert_equal 'disabled', afu_match.db_match.reload.offers.first.stat
  end

  # def test_add_stake!
  #   @open.add_stake!(team: 'h', offer: 'ou', amount: 15_000)
  #   assert_equal 15_000, @open[:h_stake]
  #   assert_equal 15_000, @open[:play][:ou][:h_stake]
  #   assert_equal 15_000, $redis.afu_match(@open.key)[:h_stake]
  #   assert_equal 15_000, $redis.afu_match(@open.key)[:play][:ou][:h_stake]
  # end

  def test_dynamic_offer
    assert_equal 'ml',        @open.ml[:type]
    assert_equal 'ou',        @open.ou[:type]
    assert_equal 'one_win',   @open.one_win[:type]
    assert_equal 'point',     @open.point[:type]
  end

  def test_broadcast_new_match
    @open.broadcast_new_match
  end

  def test_reload
    assert_equal @open, @open.reload
  end

  def test_start_time_to_i
    assert @open[:start_time_int].is_a?(Integer)
  end
end
