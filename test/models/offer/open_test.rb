require "test_helper"

class Offer::OpenTest < ActiveSupport::TestCase
  def setup
    @match     = create(:match, :with_category, :with_team, :with_book_maker, :with_offers, :with_group)
    @afu_match = @match.open!
  end

  def test_sync
    ou = Offer.find_by(name: "ou", match_id: @match.id)
    create(:offer_asian, 
           name: "ou", 
           offer_id: ou.id,
           asian_head: 5,
           asian_proportion: 60
          )
    ou.sync_cache
    afu_offer = @afu_match.reload.ou
    assert_equal 5, afu_offer[:handicapped][:head]
    assert_equal 60, afu_offer[:handicapped][:proportion]
  end

  def test_afu_match
    assert_equal @afu_match, @afu_match.point.match
  end

  def test_db_offer
    assert_equal Offer.find(@afu_match.point[:offer_id]), @afu_match.point.db_offer
  end

  def test_head_h
    offer = create(:random_offer, name: 'point', head: -6.5)
    assert_equal 'h', offer.to_open(@match.key)[:head]
  end

  def test_head_a
    offer = create(:random_offer, name: 'point', head: 3.5)
    assert_equal 'a', offer.to_open(@match.key)[:head]
  end

  def test_handicapped_head
    offer = create(:random_offer, name: 'point', head: -6.5)
    assert_equal 6.5, offer.to_open(@match.key)[:handicapped][:head]
  end
end

