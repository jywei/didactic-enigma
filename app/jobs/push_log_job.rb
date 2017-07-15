class PushLogJob < ApplicationJob
  queue_as :push_log

  def perform(attributes = {})
    # columns = "ot_type, action, log, tx_offer_id, tx_match_id, data, ot, head, ot_name, h_oppo, a_oppo, d_oppo, book_maker_id, tx_offer, tx_match, log_start, log_duration, tx_timestamp, has_error"
    # a = attributes
    # values = "'#{a[:ot_type]}', '#{a[:action]}', '#{a[:log]}', '#{a[:tx_offer_id]}', #{a[:tx_match_id]}, "
    # strings = attributes.reduce({columns: '', values: ''}) do |result, pair|
    #   result[:columns] << "#{pair[0]}, "
    #   result[:values]  << "'#{pair[1]}', "
    #   result
    # end
    # strings[:values] = strings[:values][0..strings[:values].size - 2]
    # $mysql.insert('log_pushes', strings[:columns], strings[:values])
    Log::Push.create!(attributes)
  end
end
