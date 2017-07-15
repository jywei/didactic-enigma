require "test_helper"

class Log::ErrorTest < ActiveSupport::TestCase
  def error
    @error ||= Log::Error.new
  end

  def test_valid
    assert error.valid?
  end
end
