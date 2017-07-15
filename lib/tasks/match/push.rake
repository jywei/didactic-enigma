namespace :match do
  task push: :environment do
    # File.open("#{Rails.root}/lib/tasks/match/push.pid", "w+") {|file| file.write(Process.pid) }
    # puts "Process running on pid #{Process.pid}"
  end
end
