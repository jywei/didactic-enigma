# [%w(test 測試), %w(soccer 足球), %w(baseball 棒球), %w(basketball 籃球), %w(tennis 網球)].each do |pair|
#   Sport.find_by(name: pair[0]).update_column(:ch, pair[1])
# end

# $redis.db.del($matches_ref)
# Match.includes(:offers).each do |match|
#   match.update_column(:book_maker_id, match.offers.first.book_maker_id)
#   $redis.db.hset($matches_ref, match.ref_key, match.id)
# end


puts 'Set default asia_prob to redis !'
AsiaOffer.default_prob($redis, "asia_prob", File.open("lib/csv/asia_prob.csv"))




puts '====== Start import default seeds ======'

['sport.rb', 'category.rb', 'book_maker.rb', 'offer_type.rb', 'role.rb', 'user.rb', 'team.rb'].each do |seed|
	filename = File.join(Rails.root, 'db', 'seeds', seed)
	if File.exist?(filename)
		load(filename)
	else
		puts "error => < #{filename} > not found."
	end
end