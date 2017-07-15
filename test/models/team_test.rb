require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  def test_invalid
    assert Team.new.valid?
  end

  def test_valid
    assert Team.new(category_id: create(:category, :nba).id).valid?
  end
end
