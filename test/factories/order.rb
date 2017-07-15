FactoryGirl.define do
  factory :order do
    time             '2016-10-13 08:00:11'
    ip               '127.0.0.1'
    user_id          1
    created_at       '2016-10-13 08:00:11'
    updated_at       '2016-10-13 08:00:11'
    amount           100
    type_flag        'normal'
    is_valid         true

    transient do
      offer          nil
    end

    after(:create) do |order, evaluator|
      offer = evaluator.offer.nil? ? create(:random_offer) : evaluator.offer
      create(:order_item, order: order, offer: offer, head: offer.head, offer_name: offer.name, sport_id: offer.category.sport.id)
    end

    trait :with_parlay do
      type_flag      'parlay'

      after(:create) do |order|
        random_offer, random_offer1 = create_list(:random_offer, 2, name: 'ou')
        create(:order_item, order: order, offer: random_offer, head: random_offer.head, offer_name: random_offer.name)
        create(:order_item, order: order, offer: random_offer1, head: random_offer1.head, offer_name: random_offer1.name)
      end
    end

  end
end
