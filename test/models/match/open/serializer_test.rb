require 'test_helper'

class Match::Open::SerializerTest < ActiveSupport::TestCase
  def setup
    @match = create(:match, :with_offers, :with_asian_offers, :with_team, :with_category, :with_book_maker, :with_group)
    @open  = @match.open!
  end

  def user
    @user ||= create(:user)
  end

  def test_admin_offer_odd
    offer = 'point'
    team  = 'h'
    time  = DateTime.mil
    hash  = @open.admin_offer_odd(offer, team, time)
    assert_equal @open[:match_id], hash[:match_id]
    assert_equal offer, hash[:offer]
    assert_equal team,  hash[:team]
    assert_equal @open.point["#{team}_modifier"], hash[:modifier]
    # assert_equal user.id, hash[:user_id]
  end

  def test_player_offer_odd
    offer = 'ml'
    team  = 'h'
    hash  = @open.player_offer_odd(offer, team, DateTime.mil)
    base  =           @open[:play][:ml][:h]
    modifier =        @open[:play][:ml][:h_modifier]
    parlay_base     = @open[:parlay][:ml][:h]
    parlay_modifier = @open[:parlay][:ml][:h_modifier]

    assert_equal @open[:match_id], hash[:match_id]
    assert_equal offer, hash[:offer]
    assert_equal team,  hash[:team]
    assert_equal (base + modifier).round(3), hash[:odd]
    assert_equal (parlay_base + parlay_modifier).round(3), hash[:parlay_odd]
    assert_equal 'odd_manual_change', hash[:action]
  end

  def test_player_offer_odd_asian
    offer = 'ml'
    team  = 'asian'
    hash  = @open.player_offer_odd(offer, team, DateTime.mil)

    base  =           @open[:play][:ml][:handicapped][:proportion]
    modifier =        @open[:play][:ml][:handicapped][:modifier]
    parlay_base     = @open[:parlay][:ml][:handicapped][:proportion]
    parlay_modifier = @open[:parlay][:ml][:handicapped][:modifier]

    assert_equal @open[:match_id], hash[:match_id]
    assert_equal offer, hash[:offer]
    assert_equal team,  hash[:team]
    assert_equal (base + modifier).round(3), hash[:proportion]
    assert_equal (parlay_base + parlay_modifier).round(3), hash[:parlay_proportion]
    assert_equal 'odd_manual_change', hash[:action]
  end


  def test_offer_stat
    offer = 'ml'
    stat  = 'normal'
    hash  = @open.offer_stat(offer: offer, stat: stat)
    assert_equal @open[:match_id], hash[:match_id]
    assert_equal offer,    hash[:offer]
    assert_equal 'normal', hash[:stat]
    assert_equal 'stat',   hash[:action]
  end

  def test_stakes_ml
    offer = 'ml'
    hash  = @open.stakes(offer)
    assert_equal @open[:match_id],   hash[:match_id]
    assert_equal @open[:h_stake],    hash[:match_h_stake]
    assert_equal @open[:a_stake],    hash[:match_a_stake]
    assert_nil   hash[:match_d_stake]
    assert_equal offer, hash[:offer]
    assert_equal @open.ml[:h_stake], hash[:offer_h_stake]
    assert_equal @open.ml[:a_stake], hash[:offer_a_stake]
    assert_nil   hash[:offer_d_stake]
  end

  def test_broadcast_scores
    assert_equal @open[:h_score], @open.broadcast_scores[:h_score]
    assert_equal @open[:a_score], @open.broadcast_scores[:a_score]
  end

  def test_gamer_leader_offer_odd
    data   = @open.gamer_leader_offer_odd('ml', DateTime.mil)
    offer  = @open.ml
    parlay = @open[:parlay][:ml]
    assert_equal offer[:h] + offer[:h_modifier], data[:h]
    assert_equal offer[:a] + offer[:a_modifier], data[:a]
    assert_equal parlay[:h] + parlay[:h_modifier], data[:parlay_h]
    assert_equal parlay[:a] + parlay[:a_modifier], data[:parlay_a]
    assert_equal Fixnum, data[:last_updated].class
  end

  def test_leader_offer_odd
    data   = @open.leader_offer_odds('ml')
    offer  = @open.ml
    parlay = @open[:parlay][:ml]
    assert_equal offer[:h], data[:h_base]
    assert_equal offer[:a], data[:a_base]
    assert_equal parlay[:h], data[:parlay_h_base]
    assert_equal parlay[:a], data[:parlay_a_base]
  end

  def test_to_gamer
    gamer = @open.to_gamer
    assert_equal @open[:match_id], gamer[:match_id]
    assert_nil   gamer[:h_stake]
    assert_nil   gamer[:a_stake]
    assert_nil   gamer[:d_stake]
    assert_nil   gamer[:play][:point][:h_stake]
    assert_nil   gamer[:play][:point][:a_stake]
    assert_nil   gamer[:play][:point][:d_stake]
    assert_nil   gamer[:play][:point][:h_modifier]
    assert_nil   gamer[:play][:point][:a_modifier]
    assert_nil   gamer[:play][:point][:d_modifier]
    assert_nil   gamer[:play][:point][:water]
  end

  def test_new_head_match_channel
    hash = @open.new_head('point', 'MatchesChannel')
    data = @open[:play][:point]
    assert_equal (data[:h] + data[:h_modifier]).round(3), hash[:h]
    assert_equal (data[:a] + data[:a_modifier]).round(3), hash[:a]
    assert_equal data[:handicapped][:head],       hash[:handicapped][:head]
    assert_equal data[:handicapped][:proportion], hash[:handicapped][:proportion]
    assert_equal data[:handicapped][:modifier],   hash[:handicapped][:modifier]
  end

  def test_new_head_player_match_channel
    hash = @open.new_head('point', 'Player::MatchesChannel')
    data = @open[:play][:point]
    assert_equal (data[:h] + data[:h_modifier]).round(3),   hash[:h]
    assert_equal (data[:a] + data[:a_modifier]).round(3),   hash[:a]
    assert_equal data[:handicapped][:head],                 hash[:handicapped][:head]
    assert_equal data[:handicapped][:proportion] + data[:handicapped][:modifier],   hash[:handicapped][:proportion]
    assert_equal nil,   hash[:handicapped][:modifier]
  end

end
