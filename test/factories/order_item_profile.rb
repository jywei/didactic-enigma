FactoryGirl.define do
  factory :order_item_profile, class: Order::Item::Profile do
    order_item_id     55
    hteam_name        Faker::Team.name
    ateam_name        Faker::Team.name
    category_name     Faker::Team.sport
    halves            "full"
    match_start_time  Faker::Time.forward(3, :morning)
  end
end
