require 'test_helper'

class BookMakerTest < ActiveSupport::TestCase
  
  def book_maker
    @book_maker ||= BookMaker.new
  end

  def test_valid
    refute book_maker.valid?
  end
end
