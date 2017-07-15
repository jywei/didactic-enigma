FactoryGirl.define do
  factory :user_profile, class: User::Profile do
    nickname          { Faker::Internet.user_name }
    note              { Faker::Lorem.characters(20) }
    quota             100
    delay_original    0
    delay_running     0
    parlay            10
    status            '正常'
    accessable        true
    current_quota     100
    quota_update_time Time.now
  end
end
