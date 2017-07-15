require 'test_helper'

class Log::CloseTest < ActiveSupport::TestCase
  def close
    @close ||= Log::Close.new(data: [1, 2, 3, 4, 5])
  end

  def test_valid
    assert close.valid?
  end

  def test_data
    close.save!
    assert_equal 2, close.data[1]
  end
end
