require 'test_helper'

class Info::OddTypeTest < ActiveSupport::TestCase
  def setup
  end

  def test_indexes
    indexes = Info::OddType.indexes
    assert_includes indexes.keys, 'point'
    assert_includes indexes.keys, 'ou'
    assert_includes indexes.keys, 'ml'
    assert_includes indexes.keys, 'one_win'
    assert_includes indexes.keys, 'odd_even'
    assert_includes indexes.keys, 'three_way'
    assert_equal    0,            indexes['point']
    assert_equal    1,            indexes['ou']
    assert_equal    2,            indexes['ml']
  end
end
