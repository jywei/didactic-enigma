FactoryGirl.define do
  factory :order_item, class: Order::Item do
    target         'h'
    odd            0.95
    offer_name     'ou'
    type_flag      'normal'
    ot_id          1

    before(:create) do |order_item|
      match = Match.last || create(:random_match)
      order_item.match = match
      order_item.sport_name = match.category.sport.name
      order_item.category_id = match.category_id
      # order_item.offer = match.offers.to_a.sample
    end

    after(:create) do |order_item|
      profile = create(:order_item_profile,
                       order_item_id:    order_item.id,
                       hteam_name:       Team.find(order_item.match.hteam_id).display_name,
                       ateam_name:       Team.find(order_item.match.ateam_id).display_name,
                       category_name:    order_item.match.category.name,
                       match_start_time: order_item.match.start_time,
                       halves:           order_item.match.halves
                       )
      order_item.profile = profile
    end
  end
end
