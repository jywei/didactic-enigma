require 'test_helper'

class Order::ItemTest < ActiveSupport::TestCase
  def setup
    @user     = create(:user)
    @match    = create(:random_match)
    @offer    = create(:offer, :with_category, :with_book_maker, match: @match, offer_category: @match.category.name)
    @order    = create(:order, user: @user, offer: @offer)
    @item     = @order.item
  end

  def test_association
    assert_equal @offer,                     @item.offer
  end

  def test_sport_name
    assert_equal @match.category.sport.name, @item.sport_name
  end

  def test_category_id
    assert_equal @match.category_id,         @item.category_id
  end

  def test_order_item_profile
    assert_equal @item.id,                   @item.profile.order_item_id
  end
end
