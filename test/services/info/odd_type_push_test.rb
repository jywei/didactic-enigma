require 'test_helper'

class Info::OddTypeTest < ActiveSupport::TestCase
  def setup
  end

  def test_singleton_methods
    assert Info::OddTypePush.full?(6)
    assert Info::OddTypePush.full?(246)
    assert Info::OddTypePush.ht?(62)
    assert Info::OddTypePush.hf?(20)

    assert Info::OddTypePush.point?(59)
    assert Info::OddTypePush.ou?(246)
  end
end
