require 'test_helper'

class OfferTest < ActiveSupport::TestCase
  def setup
    @match = create(:match, :with_category, :with_team, :with_book_maker, :with_group)
    @offer = create(:offer, :with_setting, :with_book_maker, :with_match, name: 'ml')
  end

  def test_flat
    create(:offer, :with_book_maker, :with_category, h_oppo: 0.7,  a_oppo: 0.75, head: 3, match: @match, name: 'point')
    flat_offer = create(:offer, :with_book_maker, :with_category, h_oppo: 0.72, a_oppo: 0.73, head: 4, match: @match, name: 'point')
    create(:offer, :with_book_maker, :with_category, h_oppo: 0.71, a_oppo: 0.74, head: 5, match: @match, name: 'point')
    create(:offer, :with_book_maker, :with_category, h_oppo: 0.74, a_oppo: 0.74, match: @match, name: 'ml')

    assert_equal flat_offer, @match.offers.flat('point')
  end

  def test_to_open
    assert_equal Info::OddType.ch, 'point' => '讓分',
                                   'ou'        => '大小',
                                   'ml'        => '獨贏',
                                   'one_win'   => '一輸二贏',
                                   'odd_even'  => '單雙',
                                   'three_way' => '三路'
  end

  def test_association_setting_and_position
    @offer.destroy
    assert_equal 0, Offer::Setting.count
  end

  def test_db_offer
    assert_equal @offer, @offer.to_open('normal').db_offer
  end

  def test_set_handicapped_team_h
    offer = create(:random_offer, name: 'point', head: -6.5)
    assert_equal 'h', offer.handicapped_team
  end

  def test_set_handicapped_team_a
    offer = create(:random_offer, name: 'point', head: 3.5)
    assert_equal 'a', offer.handicapped_team
  end

  def test_sync_cache_assign
    @offer.update_parlay
    afu_match = @offer.match.open!
    offer = create(:offer, :with_setting, :with_book_maker, match: @offer.match, category_id: @offer.match.category_id, name: 'ou')
    offer.sync_cache(afu_match: afu_match)
    afu_offer = afu_match.reload[:play][:ou]
    refute_equal 0.0, offer.h_odd.to_f
    refute_equal 0.0, offer.a_odd.to_f
    assert_equal offer.h_odd.to_f.round(3), afu_offer[:h]
    assert_equal offer.a_odd.to_f.round(3), afu_offer[:a]
  end

  def test_sync_cache_update
    @offer.update_parlay
    afu_match = @offer.match.open!
    @offer.update(h_odd: 0.98, a_odd: 0.97)
    @offer.sync_cache(afu_match: afu_match)
    offer = afu_match.reload[:play][@offer.name.to_sym]

    assert_equal 0.98, offer[:h]
    assert_equal 0.97, offer[:a]
  end

  def test_sync_cache_create_parlay_and_assign
    afu_match = @offer.match.open!
    @offer.sync_cache(afu_match: afu_match)
    offer = afu_match.reload[:parlay][@offer.name.to_sym]

    refute_equal 0.0, @offer.parlay.h_odd.to_f
    refute_equal 0.0, @offer.parlay.a_odd.to_f
    assert_equal @offer.parlay.h_odd.to_f, offer[:h].to_f
    assert_equal @offer.parlay.a_odd.to_f, offer[:a].to_f
  end
end
