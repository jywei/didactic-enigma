require 'faker'

puts 'creating test category'
c = Category.find_or_create_by(name: 'EES', sport: Sport.find_or_create_by(name: 'test', leader_spid: 888, ch: '測試', active: true), slug: 'TT', mgid: 8888)
$g1 = Group.find_or_create_by(tx_name: "測試A", display_name: "測試A", category_id: c.id)
$g2 = Group.find_or_create_by(tx_name: "測試B", display_name: "測試B", category_id: c.id)
$c = c

puts 'recreating teams'
Team.where(tx_id: (1..100).to_a).destroy_all
(1..100).to_a.each do |tx_id|
  Team.create!(name: Faker::Name.first_name, tx_id: tx_id)
end
$team_ids = Team.where(tx_id: (1..100).to_a).ids

puts 'cleaning up fake matches'
c.matches.destroy_all

def fake_matches(count, category_id, team_ids)
  matches = []
  count.times do
    matches << {
      start_time: Time.now + (-3..5).to_a.sample.day + (-24..24).to_a.sample.hour,
      hteam_id: team_ids.sample,
      ateam_id: team_ids.sample,
      active: true,
      stat: 'normal',
      leader: 'tx',
      leader_id: Faker::Number.between(1, 20_000),
      category_id: category_id,
      halves: %w(full ht hf q1 q2 q3 q4).sample,
      book_maker_id: BookMaker.all.ids.sample,
      group_id: [$g1, $g2].sample.id
    }
  end
  matches
end

def fake_offers(match)
  %w(point ou three_way one_win odd_even).each do |name|
    modifier = %w(-0.05 -0.04 -0.03 -0.02 -0.01 0.00 0.02 0.03 0.04 0.05).sample.to_f
    # Offer.create!(
    values = {
      name: name,
      h_odd: Faker::Number.between(0.90, 1.25),
      a_odd: Faker::Number.between(0.90, 1.25),
      h_modifier: modifier,
      a_modifier: 0.0 - modifier,
      handicapped_team: %w(h a).sample,
      head: (1..10).to_a.sample,
      asian_proportion: %w(-30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30).sample,
      asian_modifier: %w(-10 -5 0 5 10).sample,
      h_stake: Faker::Number.between(10_000, 100_000),
      a_stake: Faker::Number.between(10_000, 100_000),
      leader: 'tx',
      stat: 'normal',
      leader_id: Faker::Number.between(1, 20_000),
      book_maker_id: BookMaker.all.ids.sample,
      match_id: match.id,
      category_id: $c.id
    }
    values.merge!(d_odd: Faker::Number.between(0.90, 1.25), d_modifier: modifier, d_stake: Faker::Number.between(10_000, 100_000)) if name == 'three_way'
    Offer.create!(values)
    # )
  end
end

puts 'creating matches for test category'
Match.create!(fake_matches(30, c.id, $team_ids))
puts 'creating offers for test category'
Match.where(category_id: c.id).each { |match| fake_offers(match) }

puts 'creating fake matches for testing orders'
def create_fake_match(team_name, tid, match_id)
  Match.where(leader_id: match_id).delete_all
  Team.where(id: [tid, tid + 25000]).delete_all
  m = Match.create!(
    start_time: Time.now + (2..5).to_a.sample.day + (-24..24).to_a.sample.hour,
    hteam_id: Team.create!(name: team_name, name_cn: team_name, category_id: $c.id, tx_id: tid).id,
    ateam_id: Team.create!(name: team_name, name_cn: team_name, category_id: $c.id, tx_id: tid + 25000).id,
    active: true,
    stat: 'normal',
    leader: 'tx',
    leader_id: match_id,
    category_id: $c.id,
    halves: 'full',
    book_maker_id: BookMaker.all.ids.sample,
    group_id: [$g1, $g2].sample.id
  )
  fake_offers(m)
end

names = [
  "odd up",
  "odd down",
  "注額超過上限",
  "不存在的玩法",
  "玩法停押",
  "玩法停盤",
  "伺服器錯誤"
]

names.each do |name|
  create_fake_match(name, 100 + names.index(name), 1234567890 + names.index(name))
end

Match.where(category_id: c.id).each(&:open!)
