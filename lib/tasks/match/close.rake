namespace :match do
  task close: :environment do
    matches = Match.includes(:offer_positions).active.authentic.outdated
    puts "#{matches.size} outdated matches found"
    ids = matches.ids
    log = Log::Close.create!(match_count: matches.size)
    matches.close! if matches.any?
    log.update!(data: ids)
    puts "Done"
  end
end
