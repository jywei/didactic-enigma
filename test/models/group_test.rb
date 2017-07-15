require "test_helper"

class GroupTest < ActiveSupport::TestCase
  def setup
    @group = create(:group, :with_category)
  end

  def test_valid
    assert @group.valid?
    assert Category.first, @group.category
  end
end
