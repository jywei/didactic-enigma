namespace :match do
  task open: :environment do
    Rake::Task['match:clean'].invoke
    Category.save_current
    Match.open!
    puts "Done! #{$redis.afu_matches.size} matches are opened!"
  end
end
