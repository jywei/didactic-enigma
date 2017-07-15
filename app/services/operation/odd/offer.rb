# 本功能已移至Go專案
# module Operation
#   class Odd
#     class Offer
#       include Operation::Odd::Helpers
#       include Operation::Odd::Algorithm
#
#       attr_reader :stat_changed, :action
#
#       def initialize(args, leader, push_log)
#         @args     = args
#         @leader   = leader
#         @push_log = push_log
#       end
#
#       def create_new
#         begin
#           @push_log.action("create")
#           @action = :create
#           @push_log.push("Looking for possible duplicate offer...")
#           @push_log.push("Offer data in database: #{db_offer.try(:attributes).as_json || 'Not Found'}")
#           offer = create_offer(db_match.try(:id))
#           if offer.match_id
#             @push_log.push("Offer is connected to #{offer.match_id}")
#           else
#             attrs = necessary_match_attributes
#             attrs[:uuid] = @push_log.uuid
#             @push_log.request("match", attrs)
#             Worker::Runner::Match.run_by_env(attrs)
#           end
#           offer
#         rescue => e
#           if db_offer_same_head
#             @push_log.push("Already created offer found: #{db_offer_same_head.try(:attributes).as_json}")
#             @action = :update
#             offer = update_db_odd_and_stat
#           else
#             @push_log.push("No existing offer not found")
#             raise e
#           end
#           if Rails.env.test?
#             raise e 
#           else
#             return offer
#           end
#         end
#       end
#
#       def update_db_odd_and_stat
#         @push_log.action('update')
#         @action = :update
#         @push_log.push("Referring db offer as #{offer_ot_name} with head #{tx_offer[:head]}")
#         offer = db_offer_same_head
#         @push_log.push("Offer found with id ##{offer.id}")
#         water = @args[:is_running] ? offer.running_water.to_f : 0.015
#         hash = {
#           h_oppo: @args[:h_oppo],
#           a_oppo: @args[:a_oppo],
#           d_oppo: @args[:d_oppo],
#           h_odd:  oppo_to_odd(@args[:h_oppo], water),
#           a_odd:  oppo_to_odd(@args[:a_oppo], water),
#           d_odd:  oppo_to_odd(@args[:d_oppo], water),
#           incoming_request: @args,
#           leader_timestamp: @args[:ts]
#         }
#
#         if @args[:offer_flags].to_s == '0' && offer.stat == 'normal'
#           hash[:stat] = 'disabled'
#           @stat_changed = true
#           @push_log.push("Changing stat from normal to disabled")
#         elsif @args[:offer_flags].to_s == '1' && offer.stat != 'normal'
#           hash[:stat] = 'normal'
#           @stat_changed = true
#           @push_log.push("Changing stat from disabled to normal")
#         end
#
#         @push_log.push("Updating offer in db with: #{hash}")
#         offer.update!(hash)
#         @push_log.push("Updated.")
#         offer.update_asia
#         offer.update_parlay
#         offer
#       end
#
#       def stat_changed?
#         @stat_changed
#       end
#     end
#   end
# end
