FactoryGirl.define do
  factory :category do
    before(:create) do |category|
      category.spid = Sport.find_by(name: 'basketball').try(:leader_spid) || create(:sport, :basketball).leader_spid
    end

    trait :nba do
      name  'NBA'
      slug  'BA'
      mgid  1082
      before(:create) do |category|
        category.spid = Sport.find_by(name: 'basketball').try(:leader_spid) || create(:sport, :basketball).leader_spid
      end
    end

    trait :basketball do
      name  'TUN'
      slug  'BA'
      mgid  0001
      before(:create) do |category|
        category.spid = Sport.find_by(name: 'basketball').try(:leader_spid) || create(:sport, :basketball).leader_spid
      end
    end

    trait :mlb do
      name  'MLB'
      slug  'BB'
      mgid  0002
      before(:create) do |category|
        category.spid = Sport.find_by(name: 'baseball').try(:leader_spid) || create(:sport, :baseball).leader_spid
      end
    end

    trait :bbjpn do
      name  'JPN'
      slug  'BB'
      mgid  0003
      before(:create) do |category|
        category.spid = Sport.find_by(name: 'baseball').try(:leader_spid) || create(:sport, :baseball).leader_spid
      end
    end

    trait :baseball do
      name  'GRE'
      slug  'BB'
      mgid  0004
      before(:create) do |category|
        category.spid = Sport.find_by(name: 'baseball').try(:leader_spid) || create(:sport, :baseball).leader_spid
      end
    end

    trait :fifa do
      name  'FIFA'
      slug  'FT'
      mgid  0005
      before(:create) do |category|
        category.spid = Sport.find_by(name: 'soccer').try(:leader_spid) || create(:sport, :soccer).leader_spid
      end
    end
  end
end
