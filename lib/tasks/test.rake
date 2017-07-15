task test: :environment do
  Dir["#{Rails.root}/test/**/test_*.rb"].each { |file| require file }
end
