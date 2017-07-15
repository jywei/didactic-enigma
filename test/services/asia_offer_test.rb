# 本功能已移至Go專案
# require 'test_helper'
#
# class AsiaOfferTest < ActiveSupport::TestCase
#   def setup
#     @asia_tool = AsiaOffer
#   end
#
#   def test_flat_offer
#     match = create(:match, :with_category, :with_team, :with_book_maker, :with_group)
#     flat_offer = create(:offer, :with_category, :with_book_maker, h_oppo: 0.509, a_oppo: 0.51, head: 5, match: match, name: 'ou')
#     i = 5
#     5.times { create(:offer, :with_category, :with_book_maker, h_oppo: (0.70 - (rand / 10)), a_oppo: (0.75 + (rand / 10)), head: i += 1, match: match, name: 'ou') }
#     assert_equal flat_offer, @asia_tool.flat(match.offers.to_a)
#   end
#
#   def test_handicap_team
#     offers = []
#     5.times { offers << create(:offer, :with_category, :with_book_maker, match: create(:match, :with_category, :with_team, :with_book_maker, :with_group), name: "point", head: (-10..10).to_a.sample, handicapped_team: nil ) }
#     offers.each do |offer|
#       assert_equal (offer.head.to_f < 0 ? :h : :a), @asia_tool.handicap_team(offer) if offer.name == "point"
#     end
#   end
#
#   def test_default_prob
#     file = File.open("lib/csv/asia_prob.csv")
#     assert_equal "Succeed set default prob", @asia_tool.default_prob($redis, "asia_prob", file)
#   end
#
#   def offer(category, name, head, h, a, h_o, a_o, halves, test_flat_head)
#     m = create(:match, :with_team, :with_book_maker, :with_category, :with_group, match_category: category, halves: halves)
#     create(:offer, :with_book_maker, :test_flat_head, match: m, name: name, head: head, h_odd: h, a_odd: a,h_oppo: h_o, a_oppo: a_o, handicapped_team: nil, halves: halves, flat_head: test_flat_head, category_id: m.category.id)
#   end
#
#   def offers
#     [
#       offer('nba',   'point', '-7.5', 1.82, 2.1 ,  0.53571, 0.46428, 'full', '-7.5'),
#       offer('nba',   'point', '-7.5', 2.1,  1.82,  0.46428, 0.53571, 'full', '-7.5'),
#       offer('nba',   'ou',    '7.5',  1.82, 2.1,   0.53571, 0.46428, 'full', '7.5'),
#       offer('nba',   'ou',    '7.5',  2.1,  1.82,  0.46428, 0.53571, 'full', '7.5'),
#       offer('mlb',   'ou',    '8.5',  1.98, 1.925, 0.49295, 0.50704, 'full', '8.5'),
#       offer('mlb',   'ou',    '6',    2.05, 1.862, 0.47597, 0.52402, 'full', '6'),
#       offer('mlb',   'ml',    '0',    2.36, 1.68,  0.41584, 0.58415, 'full', '8.5'),
#       offer('mlb',   'ml',    '0',    2,    1.925, 0.49044, 0.50955, 'full', '6'),
#       offer('bbjpn', 'ou',    '11.5', 1.9,  1.76,  0.48087, 0.51912, 'full', '11.5'),
#       offer('bbjpn', 'ou',    '10.5', 1.9,  1.76,  0.48087, 0.51912, 'full', '10.5'),
#       offer('bbjpn', 'point', '-1.5', 1.9,  1.76,  0.48087, 0.51912, 'full', '10.5')
#     ]
#   end
#
#   def set_asian_prob
#     @asia_tool.default_prob($redis, "asia_prob", File.open("lib/csv/asia_prob.csv"))
#   end
#
#   # Unit test
#   def test_convert_to_asia
#     set_asian_prob
#     flat_heads  = %w(-7.5 -7.5 7.5  7.5  8.5  6    8.5   6    11.5  10.5  10.5)
#     result_asia = %w(8-50 7+50 9+50 6-50 8-90 6+50 2+100 0-40 11-50 10-60 1-70)
#     default_prob = @asia_tool.get_default_prob($redis, "asia_prob")
#     offers.each.with_index(0) do |offer, index|
#       standard = @asia_tool.convert_to_asia_with_head(offer, default_prob, flat_heads[index]).dig(:asia, :asia_format, :standard)
#       assert_equal result_asia[index], standard
#     end
#   end
#
#   # Integration test
#   def test_offer_asian_callbacks_generate_correct_values
#     set_asian_prob
#     result_asia = %w(8-50 7+50 9+50 6-50 8-90 6+50 2+100 0-40 11-50 10-60 1-70)
#     offers.each.with_index(0) do |offer, index|
#       offer.update_asia
#       offer.update_parlay
#       assert_equal result_asia[index], offer.reload.asian.asia_format
#     end
#   end
# end
