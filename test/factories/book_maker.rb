FactoryGirl.define do
  factory :book_maker do
    name Faker::Name.name


    trait :pinnacle do
      name 'PinnacleSports'
      tx_id 83
    end

  end
end
