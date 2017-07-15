require "test_helper"

class Log::PositionTest < ActiveSupport::TestCase
  def setup
    @match          = create(:random_match)
    @match.open!
    @redis_match    = $redis.afu_match(@match.redis_id)
    @user         ||= create(:user)
    @user_profile   = create(:user_profile, user_id: @user.id)
    @player_channel = "user_#{SecureRandom.hex(5)}"
    @user_channel   = "user_#{SecureRandom.hex(5)}"
  end

  def position
    @position ||= Log::Position.new
  end

  def hash1(team = 'h', offer = 'ml')
    {
      amount: 2000,
      prize: 1900,
      rate_mode: 'default',
      items: [
        {
          match_id: @redis_match.key,
          team: team,
          offer: offer,
          odd: 0.95
        }
      ]
    }
  end

  def item
    hash1[:items].first
  end

  def normal_order_args
    args =
      hash1.merge(
        match_id: item[:match_id],
        team:     item[:team],
        offer:    item[:offer],
        odd:      item[:odd]
      )
    args.delete(:items)
    args
  end

  def hash2(team = 'h', offer = 'ml')
    {
      match_id:  @redis_match.key,
      team:      team,
      offer:     'ml',
      threshold: 300
    }
  end

  def test_update_position_to_log_from_orders
    Operation::Order.new(hash1, @user, @player_channel, @user_channel, "127.0.0.1").place!
    @redis_match.adjust_position_from_orders!(normal_order_args)

    offer = @redis_match[:play][hash1[:items][0][:offer]]
    offer.update_position_to_log_from(normal_order_args)

    assert_equal offer[:positions][:h], Log::Position.find_by(order_id: Order.last.id).h_position
    refute Log::Position::Warning.last
  end

  def test_update_position_to_log_from_threshold
    hash3 = hash2.merge!(user_id: @user.id)
    @redis_match.adjust_position_from_thresholds!(hash3)

    offer = @redis_match[:play][hash3[:offer]]
    offer.update_position_to_log_from(hash3)
    assert_equal offer[:thresholds][:h], Log::Position.find_by(user_id: @user.id).h_threshold.to_f
    assert Log::Position::Warning.last
    assert_equal "Over 100% warning", Log::Position::Warning.last.warning_level
  end

  def test_warning_position_log_from_threshold_and_order
    hash4 = hash2.merge!(user_id: @user.id, threshold: -2_500)
    @redis_match.adjust_position_from_thresholds!(hash4)
    offer = @redis_match[:play][hash4[:offer]]
    offer.update_position_to_log_from(hash4)

    Operation::Order.new(hash1, @user, @player_channel, @user_channel, "127.0.0.1").place!
    @redis_match.adjust_position_from_orders!(normal_order_args)
    offer.update_position_to_log_from(normal_order_args)

    assert_equal offer[:thresholds][:h], Log::Position.find_by(user_id: @user.id).h_threshold.to_f
    assert_equal "Over 75% warning", Log::Position::Warning.last.warning_level
  end
end
