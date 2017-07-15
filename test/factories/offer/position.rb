FactoryGirl.define do
  factory :offer_position, class: Offer::Position do
    h_position  0.000
    a_position  0.000
    d_position  0.000
    h_distance  0.000
    a_distance  0.000
    d_distance  0.000
    h_threshold -200.000
    a_threshold -200.000
    d_threshold -200.000
    offer_name 'three_way'

    trait :ou do
      offer_name 'ou'
    end

    trait :point do
      offer_name 'point'
    end

    trait :one_win do
      offer_name 'one_win'
    end

    trait :odd_even do
      offer_name 'odd_even'
    end

  end
end
