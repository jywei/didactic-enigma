require "test_helper"

class Match::ResultTest < ActiveSupport::TestCase
  def result
    @result ||= Match::Result.new
  end

  def test_valid
    # assert result.valid?
  end
end
