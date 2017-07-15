# 本功能已移至Go專案
# require 'test_helper'
#
# class Operation::OddPushLogTest < ActiveSupport::TestCase
#   def setup
#     create(:book_maker, :pinnacle)
#     category           = create(:category, :nba)
#     @tx_match_id       = '999'
#     @tx_offer_id       = '888'
#     @tx_offer_id_point = '777'
#     @tx_offer_id_three_way = '666'
#     hteam_id           = create(:team, category_id: category.id).tx_id
#     ateam_id           = create(:team, category_id: category.id).tx_id
#     $redis.hset("tx_matches:#{Time.now.strftime('%Y-%m-%d')}", @tx_match_id, {
#       hteam_id:   hteam_id,
#       ateam_id:   ateam_id,
#       start_time: (Time.now + 1.day).utc.strftime('%Y-%m-%d %H:%M:%S UTC'),
#       hteam:      'foo',
#       ateam:      'bar',
#       mgid:       category.mgid,
#       offer_id:   %w(666 777 888)
#     }.to_marshal)
#
#     $redis.hset("tx_offers:#{Time.now.strftime('%Y-%m-%d')}", @tx_offer_id, {
#       ot_id: 245,
#       match_id: @tx_match_id,
#       bid: 83,
#       head: 0
#     }.to_marshal)
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
#       sport_id:     1,
#       offer_flags:  1,
#       last_updated: (Time.now - 2.seconds).utc.strftime('%Y-%m-%d %H:%M:%S UTC'),
#       result:       nil
#     }
#   end

  # def test_match_does_not_exist_log
  #   match_id = '567890'
  #   Operation::Odd.new(@message.merge(match_id: match_id).to_base64).operate!
  #   assert_equal 1, Log::Push.count
  #   assert_equal match_id, Log::Push.last.tx_match_id.to_s
  #   assert_includes Log::Push.last.log, "#{match_id} is not found"
  # end
  #
  # def test_offer_does_not_exist_log
  #   offer_id = '113355'
  #   Operation::Odd.new(@message.merge(offer_id: offer_id).to_base64).operate!
  #   assert_equal 1, Log::Push.count
  #   assert_equal @tx_match_id, Log::Push.last.tx_match_id.to_s
  #   assert_equal offer_id, Log::Push.last.tx_offer_id.to_s
  #   refute_includes Log::Push.last.log, "#{@tx_match_id} is not found"
  #   assert_includes Log::Push.last.log, "#{offer_id} is not found"
  # end
  #
  # def test_ot_does_not_exist_log
  #   $redis.hset("tx_offers:#{Time.now.strftime('%Y-%m-%d')}", @tx_offer_id, {
  #     ot_id: 2488,
  #     match_id: @tx_match_id,
  #     bid: 83,
  #     head: 0
  #   }.to_marshal)
  #   Operation::Odd.new(@message.to_base64).operate!
  #   assert_equal 1, Log::Push.count
  #   assert_equal @tx_match_id, Log::Push.last.tx_match_id.to_s
  #   assert_equal @tx_offer_id, Log::Push.last.tx_offer_id.to_s
  #   refute_includes Log::Push.last.log, "#{@tx_match_id} not found"
  #   refute_includes Log::Push.last.log, "#{@tx_offer_id} not found"
  #   assert_includes Log::Push.last.log, 'not in current available ot'
  # end

  # def test_afu_match_and_offer_available
  #   Operation::Odd.new(@message.to_base64).operate!
  #   assert_equal 4, Log::Push.count
  #   assert_includes Log::Push.last.log, "#{@tx_match_id} is found"
  #   assert_includes Log::Push.last.log, "#{@tx_offer_id} is found"
  # end

  # def test_duration
  #   Operation::Odd.new(@message.to_base64).operate!
  #   assert_equal 1, Log::Push.count
  #   assert Log::Push.last.log_start
  #   assert Log::Push.last.log_duration
  # end
  #
  # def test_no_exception
  #   Operation::Odd.new(@message.to_base64).operate!
  #   assert_equal 1, Log::Push.count
  #   assert_equal 'create_offer', Log::Push.last.action
  #   refute Log::Push.last.has_error
  # end
  #
  # def test_no_category
  #   $redis.hset("tx_matches:#{Time.now.strftime('%Y-%m-%d')}", @tx_match_id, {
  #     mgid:       1234567
  #   }.to_marshal)
  #   Operation::Odd.new(@message.to_base64).operate!
  #   assert_equal 1, Log::Push.count
  #   assert_equal 'drop(no_category)', Log::Push.last.action
  # end
# end
