require 'test_helper'

class SportTest < ActiveSupport::TestCase
  def setup
    @baseball   = create(:sport, :baseball)
    @basketball = create(:sport, :basketball, active: false)
  end

  def test_active
    assert_includes Sport.active, @baseball
    refute_includes Sport.active, @basketball
  end
end
