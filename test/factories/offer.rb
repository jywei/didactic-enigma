FactoryGirl.define do
  factory :offer do
    modifier = %w(-0.05 -0.04 -0.03 -0.02 -0.01 0.00 0.02 0.03 0.04 0.05).sample.to_f
    h_odd            Faker::Number.between(0.90, 1.25)
    a_odd            Faker::Number.between(0.90, 1.25)
    h_oppo           Faker::Number.between(0.30, 0.49)
    a_oppo           Faker::Number.between(0.51, 0.60)
    h_modifier       modifier
    a_modifier       0.0 - modifier
    handicapped_team { %w(h a).sample }
    head             {
                        heads = ::Offer.all.pluck(:head).to_a
                        h = heads.sample || (1..10).to_a.sample
                        while h.in?(heads)
                          h += 1
                        end
                        h
                     }
    asian_proportion %w(-30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30).sample
    asian_modifier   %w(-10 -5 0 5 10).sample
    name             %w(ml ou point odd_even one_win).sample
    water            0.015
    leader           'tx'
    leader_id        { Faker::Number.number(8) }
    updated_at       Time.now
    stat             'normal'
    halves           'full'

    trait :with_match do
      before(:create) do |offer|
        match = create(:match, :with_category, :with_team, :with_book_maker, :with_group)
        offer.match           = match
        offer.category        = match.category
        offer.book_maker_id   = match.book_maker_id
        offer.halves          = match.halves
        offer.match_leader_id = match.leader_id
      end
    end

    trait :test_flat_head do
      transient do
        flat_head 0
      end
      before :create do |offer, evaluator|
        offer.test_flat_head = evaluator.flat_head
      end
    end

    trait :with_category do
      transient do
        offer_category 'nba'
      end
      before :create do |offer, evaluator|
        name = evaluator.offer_category
        cat_id = Category.find_by_name(name).id ||
                 offer.match.try(:category).try(:id) ||
                 create(:category, name.to_sym).id
        offer.category_id = cat_id
      end
    end

    trait :自然產生 do
      after(:create) do |offer|
        offer.update_asia
        offer.update_parlay
      end
    end

    trait :with_book_maker do
      before(:create) do |offer|
        book_maker = BookMaker.first || create(:book_maker)
        offer.book_maker_id = book_maker.id
      end
    end

    trait :with_setting do
      after(:create) do |offer|
        create(:offer_setting, offer: offer)
      end
    end

    trait :with_h_handicapped_team do
      after(:create) do |offer|
        offer.update_column(:handicapped_team, 'h')
      end
    end

    factory :random_offer, traits: %i(with_match with_setting with_book_maker with_category)
    factory :default_offer, traits: %i(with_book_maker with_category)
  end
end
