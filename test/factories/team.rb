FactoryGirl.define do
  factory :team do
    name    { Faker::Team.name }
    name_cn { Faker::Name.first_name }
    tx_id   { Faker::Number.number(7) }
  end
end
