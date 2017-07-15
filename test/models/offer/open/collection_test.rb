require "test_helper"

class Offer::Open::CollectionTest < ActiveSupport::TestCase
  def setup
    @match     = create(:match, :with_category, :with_team, :with_book_maker, :with_offers, :with_group)
    @afu_match = @match.open!
  end

  def test_match
    assert_equal @afu_match, @afu_match.offers.match
  end
end
