# 本功能已移至Go專案
# module Operation
#   class Odd
#     class Running
#       include Operation::Odd::Helpers
#
#       def initialize(args, uuid)
#         @args = args
#         @uuid = uuid
#       end
#
#       def update_running_ball
#         @match  = db_match
#         @offers = db_offers
#         @offer  = @offers.first
#         return if (@offer.is_running && @match.is_running) || @match.nil?
#         update_running_status_in_all_db
#         hash = {
#           action: 'running', 
#           match_key: @match.key, 
#           offer_name: @offer.name,
#           uuid: @uuid
#         }
#         Worker::Runner::Cache.run_by_env(hash)
#       end
#
#       def update_running_status_in_all_db
#         ::Match.transaction do
#           offers = @match.offers
#           unless @match.is_running
#             @match.update!(is_running: true, stat: 'normal')
#             offers.where(is_running: false).where.not(name: @offer.name).update_all(stat: 'disabled')
#           end
#           offers.where(is_running: false, name: @offer.name).update_all(stat: 'normal', is_running: true)
#         end
#       end
#
#     end
#   end
# end
