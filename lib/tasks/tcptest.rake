# require 'socket'

# task tcptest: :environment do
#   offer   = ARGV[1].gsub(/=/, ":")
#   parlay  = ARGV[2] ? ARGV[2].gsub(/=/, ":") : nil
#   message = offer + (parlay ? ":" + parlay : "")
#   s = TCPSocket.new "localhost", 20000
#   s.write(message)
# end
