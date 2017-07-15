namespace :match do
  task import: :environment do
    dates = [0, 1].map { |n| (Date.today + n.day).strftime('%Y-%m-%d') }
    Operation::Match.new(code: 0, date: dates).operate!
  end
end
