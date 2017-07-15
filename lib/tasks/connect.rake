#ws測試連線

# task connect: :environment do
#   require 'faye/websocket'
#   require 'eventmachine'

#   EM.run do
#     $ws = Faye::WebSocket::Client.new('ws://127.0.0.1:3000/api/v1/channels')
#     $ws.on(:open) do |_event|
#       puts 'Connected!'
#       $ws.send(
#         {
#           'command'    => 'subscribe',
#           'identifier' => '{"channel":"OperationsChannel"}'
#         }.to_json
#       )
#     end
#     $ws.on(:message) do |event|
#       data = JSON.parse(event.data)
#       if data['type'] == 'confirm_subscription'
#         identifier = JSON.parse(data['identifier'])
#         if identifier['channel'] == 'OperationsChannel'
#           $ws.send(
#             {
#               'command'    => 'message',
#               'identifier' => '{"channel":"OperationsChannel"}',
#               'data' => '{"action":"odd_update","foo":"bar","message":"zzz"}'
#             }.to_json
#           )
#         end
#       end
#     end
#   end
# end
