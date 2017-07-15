require "test_helper"

class Offer::AsianTest < ActiveSupport::TestCase
  def setup
    @point = create(:offer, :with_setting, :with_book_maker, :with_match, name: 'point')
    @asian = create(:offer_asian, offer: @point)
  end

  def test_db_offer
    open = @point.to_open('normal')
    open[:asian_new] = true
    open[:offer_id] = @asian.id
    assert_equal @asian, open.db_offer
  end

  def test_asian?
    assert @asian.asian?
  end
end
