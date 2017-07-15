FactoryGirl.define do
  factory :offer_asian, class: Offer::Asian do
    modifier = %w(-0.05 -0.04 -0.03 -0.02 -0.01 0.00 0.02 0.03 0.04 0.05).sample.to_f
    h_odd            0.95
    a_odd            0.95
    # h_odd            Faker::Number.between(0.90, 1.25)
    # a_odd            Faker::Number.between(0.90, 1.25)
    h_modifier       modifier
    a_modifier       0.0 - modifier
    handicapped_team %w(h a).sample
    asian_proportion %w(-30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30).sample
    asian_head       1
    asian_modifier   %w(-10 -5 0 5 10).sample
    h_stake          0
    a_stake          0
    asia_format      175
    orgin_asia_format 175
    name             %w(ml ou point odd_even one_win).sample
    water            0.015
    flag             true
    flat_head        '0.0'
    updated_at Time.now

  end
end
