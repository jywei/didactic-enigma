require 'test_helper'

class Operation::MatchTest < ActiveSupport::TestCase
  def setup
    hteam    = create(:team, name: 'foo')
    ateam    = create(:team, name: 'bar')
    category = create(:category, :nba)
    @book_maker = create(:book_maker, :pinnacle)
    @offer_ids  = [2000, 2001, 2002, 2003, 2004]
    @extra_id   = 2005
    @ids        = [1000, 1001, 1002, 1004, 1005]
    @tx_id      = '123456'
    @league     = 'NBA'
    @date       = '2016-07-12'
    # Rake::Task['redis:tx:update'].invoke
    Team.update_teamid_to_id
    Category.update_mgid_to_id
    BookMaker.update_bid_to_id
    $redis.db.set('tx_teams', Marshal.dump(hteam.tx_id => hteam.name,
                                           ateam.tx_id => ateam.name))
    $redis.db.mapped_hmset("tx_matches:#{@date}",
                           @tx_id => Marshal.dump(hteam:      hteam.name,
                                                  ateam:      ateam.name,
                                                  hteam_id:   hteam.tx_id,
                                                  ateam_id:   ateam.tx_id,
                                                  start_time: '2016-05-22 10:10',
                                                  offer_id:   @offer_ids << @extra_id,
                                                  mgid:       category.mgid))
    $redis.db.mapped_hmset("tx_offers:#{@date}",
                           @offer_ids.each_with_object({}) do |id, result|
                             ot_type = Info::OddType.basics.sample
                             result[id.to_i] = Marshal.dump(d_oppo:           0.87,
                                                            h_oppo:           0.81,
                                                            a_oppo:           0.82,
                                                            water_proportion: 0.01,
                                                            head:             0,
                                                            bid:              83,
                                                            ot:               ot_type[:ot],
                                                            ot_name:          ot_type[:ot_fullname])
                           end.merge(@extra_id => Marshal.dump(d_oppo:           0.87,
                                                               h_oppo:           0.81,
                                                               a_oppo:           0.82,
                                                               water_proportion: 0.01,
                                                               head:             -1.5,
                                                               bid:              83,
                                                               ot:               3,
                                                               ot_name:          'points')))
    @message = {
      code: 0,
      msg:  '',
      date: @date
    }.to_marshal
  end

  # def test_match
  #   Operation::Match.new(@message).operate!
  #   assert_equal 1, Match.count
  #   assert_equal 6, Offer.count
  #   assert_equal 1, Offer.where(name: 'one_win').size
  #   assert_equal 0.81, Offer.first.h_oppo.to_f
  #   assert_equal 0.82, Offer.first.a_oppo.to_f
  # end

  # def test_oppo_to_odd
  #   assert_equal 0.942, Operation::Match.new(@message).oppo_to_odd(0.5, 0.015)
  #   assert_equal 1.02, Operation::Match.new(@message).oppo_to_odd(0.48, 0.015)
  # end
end
