require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  def setup
    @category = create(:category, name: 'GG', slug: 'CC', mgid: 9999)
    @soccer   = create(:category, name: 'DD', slug: 'FB', mgid: 99999, id: 55_555)
  end

  def test_current
    assert_equal Category.offers.keys, Category.current.keys
  end

  def test_league_name
    assert_equal 'CCGG', @category.league_name
  end

  def test_save_current
    Category.save_current
    assert_equal '55555', $redis.db.hget($categories_key, 'soccer')
  end

  def test_offers
    ofs = Category.offers
    assert_includes ofs['soccer'].map   { |n| n['en'] }, 'three_way'
    refute_includes ofs['soccer'].map   { |n| n['en'] }, 'ml'
    refute_includes ofs['baseball'].map { |n| n['en'] }, 'three_way'
    refute_includes ofs['tennis'].map   { |n| n['en'] }, 'three_way'
    refute_includes ofs['test'].map     { |n| n['en'] }, 'three_way'
  end
end
