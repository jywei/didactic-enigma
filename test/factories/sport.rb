FactoryGirl.define do
  factory :sport do
    active true

    trait :soccer do
      id 75
      leader_spid 1
      name 'soccer'
      display_name '足球'
    end

    trait :ice_hockey do
      id 76
      leader_spid 2
      name 'ice hockey'
      display_name '冰球'
    end

    trait :basketball do
      id 77
      leader_spid 3
      name 'basketball'
      display_name '籃球'
    end

    trait :rugby_union do
      id 78
      leader_spid 4
      name 'rugby union'
      display_name '橄欖球'
    end

    trait :tennis do
      id 79
      leader_spid 5
      name 'tennis'
      display_name '網球'
    end

    trait :us_football do
      id 80
      leader_spid 6
      name 'us football'
      display_name '美式足球'
    end

    trait :baseball do
      id 81
      leader_spid 7
      name 'baseball'
      display_name '棒球'
    end

    trait :volleyball do
      id 87
      leader_spid 13
      name 'volleyball'
      display_name '排球'
    end

  end
end
