# 本功能已移至Go專案
# require 'test_helper'
#
# class Operation::OddRunningTest < ActiveSupport::TestCase
#   def setup
#     # @match.open!
#     # @offer = @match.offers.where(name: 'ou').first
#     @book_maker = create(:book_maker, :pinnacle)
#     category               = create(:category, :nba)
#     @tx_match_id           = '999'
#     @tx_offer_id           = '888'
#     @tx_offer_id_point     = '777'
#     @tx_offer_id_point_2   = '555'
#     @tx_offer_id_three_way = '666'
#     hteam_id               = create(:team, category_id: category.id).tx_id
#     ateam_id               = create(:team, category_id: category.id).tx_id
#     $redis.hset("tx_matches:#{Time.now.strftime('%Y-%m-%d')}", @tx_match_id, {
#       hteam_id:     hteam_id,
#       ateam_id:     ateam_id,
#       start_time:   (Time.now + 1.day).utc.strftime('%Y-%m-%d %H:%M:%S UTC'),
#       hteam:        'foo',
#       ateam:        'bar',
#       mgid:         category.mgid,
#       offer_id:     %w(666 777 888)
#     }.to_json)
#
#     $redis.hset("tx_offers:#{Time.now.strftime('%Y-%m-%d')}", @tx_offer_id, {
#       ot_id:        61,
#       match_id:     @tx_match_id,
#       bid:          83,
#       head:         0,
#       h_oppo:       0.37,
#       a_oppo:       0.31,
#       d_oppo:       0.32
#     }.to_json)
#
#     @message = {
#       code:         1,
#       match_id:     @tx_match_id,
#       msg:          'foobar',
#       offer_id:     @tx_offer_id,
#       h_oppo:       0.44,
#       a_oppo:       0.49,
#       d_oppo:       0.07,
#       head:         10,
#       sport_id:     2,
#       offer_flags:  1,
#       last_updated: (Time.now - 2.seconds).utc.strftime('%Y-%m-%d %H:%M:%S UTC'),
#       result:       nil,
#       is_running:   0
#     }
#   end
#
#   def afu_match
#     @afu_match ||= $redis.afu_match!(Match.last.key)
#   end
#
#   def test_operate_running_ball
#     Operation::Odd.new(@message).operate!
#     Operation::Odd.new(@message.merge!(is_running: 1)).operate!
#     assert_equal true, afu_match["is_running"]
#     assert_equal true, afu_match["play"]["ou"]["is_running"]
#     assert_equal true, afu_match["parlay"]["ou"]["is_running"]
#     assert_equal true, afu_match.db_match.reload.is_running
#     assert_equal true, Offer.last.reload.is_running
#   end
#
#   def test_running_ball_water_update
#     Operation::Odd.new(@message).operate!
#     Operation::Odd.new(@message.merge!(is_running: 1)).operate!
#     assert_equal 1.228, afu_match["play"]["ou"]["h"].to_f
#     assert_equal 1.228, Offer.last.reload.h_odd.to_f
#   end
#
#   def test_disable_unlive_offers_in_redis
#     Operation::Odd.new(@message).operate!
#     $redis.hset("tx_offers:#{Time.now.strftime('%Y-%m-%d')}", @tx_offer_id_point, {
#       ot_id:    59,
#       match_id: @tx_match_id,
#       bid:      83,
#       h_oppo:   0.88,
#       a_oppo:   0.11,
#       d_oppo:   0.01,
#       head:     8
#     }.to_json)
#     Operation::Odd.new(@message.merge!(offer_id: @tx_offer_id_point)).operate!
#     Operation::Odd.new(@message.merge!(is_running: 1, offer_id: @tx_offer_id)).operate!
#     assert_equal 'normal',      afu_match["play"]["ou"]["stat"]
#     assert_equal 'normal',      afu_match["parlay"]["ou"]["stat"]
#     assert_equal 'disabled',    afu_match["play"]["point"]["stat"]
#     assert_equal 'unavailable', afu_match["play"]["ml"]["stat"]
#   end
#
#   def test_disable_unlive_offers_in_db
#     Operation::Odd.new(@message).operate!
#     $redis.hset("tx_offers:#{Time.now.strftime('%Y-%m-%d')}", @tx_offer_id_point, {
#       ot_id:    59,
#       match_id: @tx_match_id,
#       bid:      83,
#       h_oppo:   0.88,
#       a_oppo:   0.11,
#       d_oppo:   0.01,
#       head:     8
#     }.to_json)
#     Operation::Odd.new(@message.merge!(offer_id: @tx_offer_id_point)).operate!
#     Operation::Odd.new(@message.merge!(is_running: 1, offer_id: @tx_offer_id)).operate!
#     assert_equal 'normal',      afu_match.db_match.reload.stat
#     assert_equal 'normal',      afu_match.db_match.offers.find_by(leader_id: @message[:offer_id]).reload.stat
#     assert_equal 'disabled',    afu_match.db_match.offers.last.reload.stat
#   end
# end
