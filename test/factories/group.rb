FactoryGirl.define do
  factory :group do
    tx_name      { Faker::Name.name }
    display_name { Faker::Name.first_name }

    trait :with_category do
      before :create do |group|
        id = Category.first || create(:category, :nba).id
        group.category_id = id
      end
    end

  end
end
