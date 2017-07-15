require 'test_helper'

class MatchesHelperTest < ActionView::TestCase
  def setup
  end

  def test_odd_to_oppo
    assert_equal [0.2369, 0.7631, 0.0], odd_to_oppo(4.1, 1.273, 0.0)
  end
end
