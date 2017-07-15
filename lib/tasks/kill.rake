# task kill: :environment do
#   term = ENV['PROCESS']
#   unless term
#     puts 'No process specified. Use: RAILS_ENV=production PROCESS=my_process rake kill'
#     exit 0
#   end
#   puts "Killing all processes: #{term}"
#   i = 0
#   processes = `ps aux | grep #{term}`
#   puts "All process count: #{processes.split("\n").size}"
#   processes.split("\n").each do |line|
#     next unless line.include?(term)
#     pid = Regexp.new(/\d{2,5}/).match(line).to_s
#     if (2..5).to_a.include?(pid.length)
#       i += 1
#       `kill -9 #{pid}`
#     end
#   end
#   puts "#{i} processes killed."
#   puts 'Done!'
#   exit 0
# end
