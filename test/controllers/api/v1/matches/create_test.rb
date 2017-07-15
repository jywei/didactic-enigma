require 'test_helper'

class Api::V1::MatchesControllerCreateTest < ActionDispatch::IntegrationTest
  # def setup
  #   hteam = create(:team, name: 'foo')
  #   ateam = create(:team, name: 'bar')
  #   create(:category, :nba)
  #   @book_maker = create(:book_maker, :pinnacle)
  #   @offer_ids  = [2000, 2001, 2002, 2003]
  #   @ids        = [1000, 1001, 1002, 1004]
  #   @tx_id      = '123456'
  #   @league     = "NBA"
  #   $redis.set("tx_matches", Marshal.dump({
  #     @tx_id => {
  #       hteam:      hteam.name,
  #       ateam:      ateam.name,
  #       hteam_id:   hteam.tx_id,
  #       ateam_id:   ateam.tx_id,
  #       start_time: '2016-05-22 10:10',
  #       offer_id:   @offer_ids
  #     }
  #   }))
  #   $redis.set("tx_offers", Marshal.dump(
  #     @offer_ids.each_with_object({}) {|id, result|
  #       result[id.to_s] = {
  #         d_oppo:           0,
  #         h_oppo:           0,
  #         a_oppo:           0,
  #         water_proportion: 0,
  #         head:             0,
  #         bid:              11,
  #         ot:               0,
  #         ot_name:          ''
  #       }
  #   }))
  # end

  # def test_create
  #   @message = Marshal.dump(
  #     {
  #       code: 1,
  #       msg: '',
  #       data: {
  #         match_id: 1,
  #         offer_id: [1,2,3,4,5]
  #       }
  #     }
  #   )
  # end
end
