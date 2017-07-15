require "test_helper"

class VigorishAncestorTest < ActiveSupport::TestCase
  def setup
    db = ActiveRecord::Base.connection
    db.execute(File.read("db/fakers/users.sql"))
    db.execute(File.read("db/fakers/user_allotters.sql"))
    db.execute(File.read("db/fakers/user_ancestors.sql"))
    db.execute(File.read("db/fakers/user_settings.sql"))
    @user     = User.last
    @match    = create(:random_match, :with_results)
    @offer    = create(:offer, :with_category, :with_book_maker, match: @match, offer_category: @match.category.name)
    @order    = create(:order, user: @user, offer: @offer, stake: 98)
  end

  def test_vigorish_ancestor
    data = VigorishAncestor::Runner.new(@order).split
    VigorishAncestor.create(data)
    vigorish_list = VigorishAncestor.first
    assert_includes 1.5..1.6       ,  vigorish_list.member.to_f
    assert_includes [-0.08, -0.075],  vigorish_list.admin.to_f
    assert_includes [-0.08, -0.075],  vigorish_list.director.to_f
  end

  def test_vigorish_share_profit_data
    data = VigorishAncestor::Runner.new(@order).split
    share_data = VigorishProfit.new(data, @order, "ancestor").share_info
    profit_data = VigorishProfit.new(data, @order, "profit").share_info
    VigorishShare.create!(share_data)
    TotalProfit.create!(profit_data)
    vigorish_share = VigorishShare.first
    total_profit   = TotalProfit.first
    assert_includes 1.5..1.6,     vigorish_share.member.to_f
    assert_equal 0,               vigorish_share.admin.to_f
    assert_includes [99.5 ,99.6], total_profit.member.to_f
    assert_includes [99.5 ,99.6], total_profit.member.to_f
  end

end
