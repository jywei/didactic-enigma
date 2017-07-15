#把線上資料灌到本機，需要搭配/db/seeds/backup.sh
# require 'colorize'

# namespace :db do
#   # Running this task under zsh: rake db:import\[name,pass\]
#   task :import, [:username, :password] => [:environment] do |task, args|
#     time = Time.now
#     path = "#{Rails.root}/db/backup/afu_production_#{Time.now.strftime("%Y%m%d%H%M%S")}.sql"
#     config = ActiveRecord::Base.connection.instance_variable_get(:@config)
#     if args[:username].blank? || args[:password].blank?
#       puts "\nUsername or Password is blank.\n\n"
#       puts "If using zsh, command should be in the following format: #{"rake db:import\\['username','password'\\]".colorize(:green)}"
#       puts "Otherwise: #{"rake db:import['username':'password']".colorize(:green)}"
#       exit
#     end

#     puts "Creating backup directory"
#     FileUtils.mkdir_p("#{Rails.root}/db/backup")
#     puts "Dumping production database"
#     `/bin/bash #{Rails.root}/db/seeds/backup.sh #{args[:username]} #{args[:password]} #{path}`
#     puts "Importing to development database"
#     `mysql -u #{config[:username]} -p#{config[:password]} -h #{config[:host]} #{config[:database]} < #{path}`
#     puts "Cleaning tmp files"
#     `rm #{path}`
#     puts "Done. Elapsed #{(Time.now - time).to_i}s."
#   end
# end
