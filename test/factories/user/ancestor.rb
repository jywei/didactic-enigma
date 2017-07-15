FactoryGirl.define do
  factory :user_ancestor, class: User::Ancestor do
    trait :with_user_id do
      user_id            500
    end

    after(:create) do |user_ancestor, evaluator|
      user_ancestor.agent             = (evaluator.user_id) - 1
      user_ancestor.general_agent     = (evaluator.user_id) - 2
      user_ancestor.shareholder       = (evaluator.user_id) - 3
      user_ancestor.major_shareholder = (evaluator.user_id) - 4
      user_ancestor.director          = (evaluator.user_id) - 5
      user_ancestor.supervisor        = (evaluator.user_id) - 6
      user_ancestor.moderator         = (evaluator.user_id) - 7
      user_ancestor.admin             = (evaluator.user_id) - 8
    end
  end
end
