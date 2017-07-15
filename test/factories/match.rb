FactoryGirl.define do
  factory :match do
    start_time  Time.now + (1..100).to_a.sample.hour
    active      true
    stat        'normal'
    leader      'tx'
    leader_id   { (100_000..1_000_000).to_a.sample }
    halves      { %w(full ht hf q1 q2 q3 q4).sample }
    # redis_id is set by model callback

    trait :full do
      halves 'full'
    end

    trait :ht do
      halves 'ht'
    end

    trait :hf do
      halves 'hf'
    end

    trait :q1 do
      halves 'q1'
    end

    transient do
      h_stake 0
      a_stake 0
    end

    trait :with_offers do
      after :create do |match, evaluator|
        %w(point ou ml one_win odd_even).each do |name|
          book_maker = BookMaker.first || create(:book_maker)
          create(:offer, :with_category, :自然產生, match_id: match.id, name: name, book_maker: book_maker, h_stake: evaluator.h_stake, a_stake: evaluator.a_stake, offer_category: match.category.name)
        end
      end
    end

    trait :with_offers_series_off do
      after :create do |match|
        %w(point ou ml one_win odd_even).each do |name|
          book_maker = BookMaker.first || create(:book_maker)
          create(:offer, :with_category, :自然產生, match_id: match.id, name: name, book_maker: book_maker, series: false, offer_category: match.category.name)
        end
      end
    end

    trait :with_invalid_offers do
      after :create do |match|
        match.offers.where("name = ? or name = ?", "one_win", "odd_even").update_all(stat: "disabled")
      end
    end

    trait :with_asian_offers do
      after :create do |match|
        %w(point ou ml one_win odd_even).each do |name|
          create(:offer_asian, offer_id: match.offers.first.id, name: name)
        end
      end
    end

    trait :with_three_way do
      after :create do |match|
        book_maker = BookMaker.first || create(:book_maker)
        create(:offer, :with_category, match_id: match.id, name: 'three_way', book_maker: book_maker)
      end
    end

    trait :with_category do
      transient do
        match_category 'nba'
      end
      before :create do |match, evaluator|
        name = evaluator.match_category
        id = (Category.find_by_name(name) || create(:category, name.to_sym)).id
        match.category_id = id
      end
    end

    trait :with_team do
      before :create do |match|
        id = (Category.all.to_a.sample || create(:category, :nba)).id
        hteam = create(:team, category_id: id)
        ateam = create(:team, category_id: id)
        match.hteam_id = hteam.id
        match.ateam_id = ateam.id
      end
    end

    trait :with_book_maker do
      before :create do |match|
        match.book_maker_id = (BookMaker.first || create(:book_maker, :pinnacle)).id
      end
    end

    trait :with_group do
      before :create do |match|
        match.group_id = (Group.first || create(:group, category_id: match.category.id)).id
      end
    end

    trait :with_results do
      h_score 100
      a_score 98
    end

    trait :with_draw_results do
      h_score 100
      a_score 100
    end

    factory :random_match, traits: %i(with_offers with_category with_team with_book_maker with_group)
  end
end
