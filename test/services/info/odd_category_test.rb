require 'test_helper'

class Info::OddTypeTest < ActiveSupport::TestCase
  def setup
    
  end

  def test_en_to_id
    assert_equal 1, Info::OddCategory.en_to_id('all')
    assert_equal 2, Info::OddCategory.en_to_id('full')
    assert_nil      Info::OddCategory.en_to_id('foobar')
  end
end
