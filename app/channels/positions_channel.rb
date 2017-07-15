require 'colorize'

class PositionsChannel < ApplicationCable::Channel
  # include ApplicationCable::Subscription
  include ApplicationCable::Authentication

  def subscribed
    if current_user.is_admin?
      stream_from channel
    end
  end

  def threshold_adjust(args)
    return unless user_identified_by? cookie_from args
    args = args.with_indifferent_access
    @match = $redis.afu_match!(args['match_id'])
    @match.adjust_position_from_thresholds!(args)
    offer = @match[:play][args[:offer]]
    offer.update_position_to_log_from(args.merge(user_id: current_user.id))
    ActionCable.server.broadcast("PositionsChannel", @match.position_update(args))
    ActionCable.server.broadcast("MatchesChannel", @match.stake_and_positions(args[:offer]))
  rescue => e
    logging_error(args, __method__, e)
    raise e
  end
end
