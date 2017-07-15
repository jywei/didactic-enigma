# require 'socket'

# task tcp: :environment do
#   server = TCPServer.new 20000
#   loop do
#     Thread.start(server.accept) do |client|
#       client_gets = client.gets
#       split_gets  = client_gets.split(":")
#       offer_id  = split_gets[1]
#       parlay_id = split_gets[3]

#       puts "content: #{client_gets}"

#       begin
#         offer = Offer.find(offer_id)
#         offer.update_asia
#         puts 'success update offer'
#       rescue
#         puts "update offer error"
#       end

#       begin
#         if parlay_id
#           attrs = Offer::Parlay.asian(offer, parlay_id)
#           return if attrs.nil?
#           parlay = Offer::Parlay.find(parlay_id)
#           parlay.asian ? parlay.asian.update!(attrs) : parlay.create!(attrs)
#           puts 'success update parlay'
#         end
#       rescue
#         puts 'update parlay error'
#       end

#       client.sendmsg("ok")
#       client.close
#     end
#   end
# end
