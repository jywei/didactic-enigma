require "test_helper"

class Offer::ParlayTest < ActiveSupport::TestCase
  def setup
    @offer = create(:offer, :自然產生, :with_match, :with_book_maker, :with_setting)
  end

  def test_transform_to_parlay
    parlay = @offer.reload.parlay
    assert_equal Offer::Parlay.oppo_to_odd(@offer.h_oppo, Offer::Parlay.parlay_water), parlay.h_odd
    refute_equal nil, parlay
  end

  def test_block_invalid_asian_ot
    AsiaOffer.default_prob($redis, "asia_prob", File.open("lib/csv/asia_prob.csv"))
    offer = create(:offer, :自然產生, :with_match, :with_book_maker, :with_setting, name: 'three_way')
    assert_equal nil, offer.reload.parlay.asian
    assert_equal nil, offer.asian
  end
end
