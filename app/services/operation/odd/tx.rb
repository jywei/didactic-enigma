# 本功能已移至Go專案
# module Operation
#   class Odd
#     module Tx
#       def tx_valid?
#         if validate_tx_match && validate_tx_offer && validate_offer_ot_type && category_found?
#           true
#         else
#           false
#         end
#       end
#
#       def category_found?
#         if Category.find_by(mgid: tx_match[:mgid])
#           true
#         else
#           ActionCable.server.config.logger.info("[#{@args[:match_id]}][跳過] 無法用mgid #{tx_match[:mgid]} 找到Category資料")
#           @push_log.push("Category with mgid #{tx_match[:mgid]} is not found in db.")
#           @push_log.action("drop(no_category)")
#           false
#         end
#       end
#
#       def validate_tx_match
#         if tx_match.nil?
#           puts "#{'Skipped:'.colorize(:blue)} Match ##{@args[:match_id]}"
#           ActionCable.server.config.logger.info("[#{@args[:match_id]}][跳過] 找不到tx_match資料")
#           @push_log.push("TX Match ID ##{@args[:match_id]} is not found in redis")
#           @push_log[:tx_match_id] = @args[:match_id]
#           @push_log[:action]      = 'drop(no_match)'
#           false
#         else
#           @push_log.push("TX Match ID ##{@args[:match_id]} is found in redis")
#           @push_log[:tx_match_id] = @args[:match_id]
#           @push_log[:tx_match]    = tx_match
#           true
#         end
#       end
#
#       def validate_tx_offer
#         if tx_offer.nil?
#           puts "#{'Skipped'.colorize(:blue)} Offer ##{@args[:offer_id]}"
#           ActionCable.server.config.logger.info("[#{@args[:match_id]}][跳過] 找不到tx_offer資料 #{@args[:offer_id]}")
#           @push_log.push("TX Offer ID ##{@args[:offer_id]} is not found in redis")
#           @push_log.assign_attributes(tx_offer_id: @args[:offer_id], action: 'drop(no_offer)')
#           @push_log[:tx_match_id] = @args[:match_id]
#           @push_log[:tx_match]    = tx_match
#           false
#         else
#           @push_log.push("TX Offer ID ##{@args[:offer_id]} is found in redis")
#           @push_log.assign_attributes(
#             tx_offer_id: @args[:offer_id], 
#             h_oppo: tx_offer[:h_oppo], 
#             a_oppo: tx_offer[:a_oppo], 
#             d_oppo: tx_offer[:d_oppo], 
#             book_maker_id: book_maker.id, 
#             tx_offer: tx_offer
#           )
#           true
#         end
#       end
#
#       def validate_offer_ot_type
#         if offer_ot_type.nil?
#           puts "#{'Skipped'.colorize(:blue)} Offer ot_id ##{tx_offer[:ot_id]} is not in current scope."
#           ActionCable.server.config.logger.info("[#{@args[:match_id]}][跳過] 球頭 #{tx_offer[:ot_id]} 不在目前範圍內")
#           @push_log.push("TX Match ID #{@args[:match_id]} TX Offer ID #{@args[:offer_id]} with ot_id #{tx_offer[:ot_id]} is not in current available ot.")
#           @push_log.assign_attributes(ot: tx_offer[:ot_id], ot_name: "(TX) #{tx_offer[:otname]}", action: 'drop(ot)')
#           false
#         else
#           @push_log.assign_attributes(ot_name: Info::OddTypePush.name(tx_offer[:ot_id], tx_offer[:head]), ot_type: offer_ot_type, ot: tx_offer[:ot_id], head: tx_offer[:head])
#           true
#         end
#       end
#     end
#   end
# end
