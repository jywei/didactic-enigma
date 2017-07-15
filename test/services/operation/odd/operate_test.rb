# 本功能已移至Go專案
# require 'test_helper'
#
# class Operation::OddOperateTest < ActiveSupport::TestCase
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
#     @tx_offer_id_ou        = '444'
#     hteam_id               = create(:team, category_id: category.id).tx_id
#     ateam_id               = create(:team, category_id: category.id).tx_id
#     $redis.hset("tx_matches:#{Time.now.strftime('%Y-%m-%d')}", @tx_match_id, {
#       hteam_id:   hteam_id,
#       ateam_id:   ateam_id,
#       start_time: (Time.now + 1.day).utc.strftime('%Y-%m-%d %H:%M:%S UTC'),
#       hteam:      'foo',
#       ateam:      'bar',
#       mgid:       category.mgid,
#       offer_id:   %w(666 777 888)
#     }.to_json)
#
#     $redis.hset("tx_offers:#{Time.now.strftime('%Y-%m-%d')}", @tx_offer_id, {
#       ot_id: 245,
#       match_id: @tx_match_id,
#       bid: 83,
#       head: 0,
#       h_oppo: 0.37,
#       a_oppo: 0.31,
#       d_oppo: 0.32,
#       group_name_ch: "美國國家籃球協會"
#     }.to_json)
#
#     @message = {
#       code:         1,
#       # match_id:     @match.leader_id,
#       match_id:     @tx_match_id,
#       msg:          'foobar',
#       # offer_id:     @offer.leader_id,
#       offer_id:     @tx_offer_id,
#       h_oppo:       0.44,
#       a_oppo:       0.49,
#       d_oppo:       0.07,
#       head:         10,
#       sport_id:     2,
#       offer_flags:  1,
#       last_updated: (Time.now - 2.seconds).utc.strftime('%Y-%m-%d %H:%M:%S UTC'),
#       result:       nil,
#       is_running:   false
#     }
#   end
#
#   def set_tx_point
#     $redis.hset("tx_offers:#{Time.now.strftime('%Y-%m-%d')}", @tx_offer_id_point, {
#       ot_id:    59,
#       match_id: @tx_match_id,
#       bid:      83,
#       head:     2
#     }.to_json)
#   end
#
#   def set_tx_ou
#     $redis.hset("tx_offers:#{Time.now.strftime('%Y-%m-%d')}", @tx_offer_id_ou, {
#       ot_id:    61,
#       match_id: @tx_match_id,
#       bid:      83,
#       head:     2
#     }.to_json)
#   end
#
#   def set_asian_data
#     AsiaOffer.default_prob($redis, "asia_prob", "#{Rails.root}/lib/csv/asia_prob.csv")
#   end
#
#   def afu_match
#     @afu_match ||= $redis.afu_match!(Match.last.key)
#   end
#
#   def test_operate_create_offer_with_match
#     Operation::Odd.new(@message).operate!
#     assert_equal 1, ::Match.all.count
#     assert_equal 1, ::Offer.all.count
#   end
#
#   def test_operate_create_match_in_redis
#     Operation::Odd.new(@message).operate!
#     assert $redis.afu_match Match.last.redis_id
#   end
#
#   def test_operate_create_offer
#     Operation::Odd.new(@message).operate!
#     set_tx_point
#     Operation::Odd.new(@message.merge(offer_id: @tx_offer_id_point)).operate!
#
#     assert_equal 1, ::Match.all.count
#     assert ::Match.last.redis_id
#     assert_equal 2, ::Offer.all.count
#     assert_equal 2, ::Offer::Parlay.all.count
#     # assert_nil   ::Offer.first.match_id
#     assert_equal 0.44, ::Offer.first.h_oppo.to_f
#     assert_equal 0.49, ::Offer.first.a_oppo.to_f
#     assert_equal ::Match.last.id, ::Offer.last.match_id
#     assert_equal 0.44, ::Offer.last.h_oppo.to_f
#     assert_equal 0.49, ::Offer.last.a_oppo.to_f
#     assert_equal Match.last.match_number, afu_match[:match_number]
#     assert_equal 'normal', afu_match.three_way[:stat]
#     assert_equal 'normal', afu_match[:parlay][:three_way][:stat]
#     assert_equal 'normal', afu_match.point[:stat]
#     assert_equal 'normal', afu_match[:parlay][:point][:stat]
#     assert_equal 2, afu_match.point[:handicapped][:head]
#
#     assert_equal 1, ::Group.all.count
#     match = ::Match.last
#     assert_equal '美國國家籃球協會', match.group.display_name
#   end
#
#   def test_operate_create_match_basketball_three_way_to_ml
#     $redis.hset("tx_offers:#{Time.now.strftime('%Y-%m-%d')}", @tx_offer_id, {
#       ot_id: 21,
#       match_id: @tx_match_id,
#       bid: 83,
#       head: 0,
#       h_oppo: 0.37,
#       a_oppo: 0.31,
#       d_oppo: 0.32
#     }.to_json)
#     Operation::Odd.new(@message.merge(sport_id: 3)).operate!
#
#     assert_equal 1, ::Match.all.count
#     assert_equal 1, ::Offer.all.count
#     refute afu_match.three_way
#     assert afu_match.ml
#   end
#
#   def test_operate_update_offer
#     Operation::Odd.new(@message).operate!
#     Operation::Odd.new(@message.merge(h_oppo: 0.47)).operate!
#     assert_equal 1.096, ::Offer.last.h_odd
#     assert_equal 1.096, afu_match.three_way[:h]
#   end
#
#   def test_operate_disable_offer
#     Operation::Odd.new(@message).operate!
#     Operation::Odd.new(@message.merge(offer_flags: 0)).operate!
#     assert_equal 'disabled', Offer.last.reload.stat
#     assert_equal 'disabled', afu_match.three_way[:stat]
#   end
#
#   def test_operate_create_parlay_and_parlay_asian
#     set_asian_data
#     set_tx_point
#     set_tx_ou
#     AsiaOffer.default_prob($redis, "asia_prob", "#{Rails.root}/lib/csv/asia_prob.csv")
#     message = @message.merge(offer_id: @tx_offer_id_ou)
#     Operation::Odd.new(message).operate!
#     assert_operator Offer::Parlay.where(type_flag: 'normal').size, :>, 0
#     assert_operator Offer::Parlay.where(type_flag: 'asian').size, :>, 0
#   end
#
#   def test_operate_update_parlay
#     set_asian_data
#     set_tx_ou
#     message = @message.merge(offer_id: @tx_offer_id_ou)
#     Operation::Odd.new(message).operate!
#     parlay = Offer.last.parlay
#     h_odd = parlay.h_odd.to_f
#     a_odd = parlay.a_odd.to_f
#     asian_head = parlay.asian.asia_format
#     Operation::Odd.new(message.merge(h_oppo: 0.66, a_oppo: 0.34)).operate!
#     refute_equal h_odd, parlay.reload.h_odd.to_f
#     refute_equal a_odd, parlay.reload.a_odd.to_f
#     refute_equal asian_head, parlay.asian.asia_format
#   end
# end
