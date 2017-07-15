require 'test_helper'

# class Redis::Lock::MatchTest < ActiveSupport::TestCase
#   def setup
#     # @lock = Redis::Lock::Match
#     @key  = "123456"
#   end
#
#   def test_lock
#     Redis::Lock::Match.lock!(@key)
#     assert Redis::Lock::Match.all.include?(@key)
#   end
#
#   def test_lock_question
#     Redis::Lock::Match.lock!(@key)
#     assert Redis::Lock::Match.lock?(@key)
#   end
#
#   def test_unlock
#     Redis::Lock::Match.lock!(@key)
#     Redis::Lock::Match.unlock!(@key)
#     refute Redis::Lock::Match.all.include?(@key)
#     refute Redis::Lock::Match.lock?(@key)
#   end
# end
