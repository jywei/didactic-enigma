require 'test_helper'

class Offer::SettingTest < ActiveSupport::TestCase
  def setup
    @match   = create(:match, :with_category, :with_team, :with_book_maker, :with_group)
    @offer   = create(:offer, :with_book_maker, :with_category, match: @match)
    @setting = create(:offer_setting, offer: @offer)
  end

  def test_relation
    assert_equal @offer, @setting.offer
  end
end
