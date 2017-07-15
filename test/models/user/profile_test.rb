require "test_helper"

class User::ProfileTest < ActiveSupport::TestCase
  def profile
    @profile ||= User::Profile.new
  end

  def test_valid
    assert profile.valid?
  end
end
