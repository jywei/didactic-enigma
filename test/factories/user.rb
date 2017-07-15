FactoryGirl.define do
  factory :user do
    username           { (Faker::Beer.name + Faker::Internet.user_name(5..8)).gsub(' ', '') }
    access_token       { Faker::Internet.password(32) }
    encrypted_password { Faker::Internet.password(5, 8) }
    # total_quota   100
    # tier     8

    # after(:create) do |user|
    #   user.bank_id = (user.id - 1)
    #   if user.tier == 8
    #     create(:user_ancestor, :with_user_id, user_id: user.id)
    #   end
    # end

  end

  trait :admin do
    is_admin true
  end

  trait :with_admin_roles do
    after :create do |user|
      {"Api::V1::AdminsController" => %w(index create update destroy role_index add_role remove_role),
       "Api::V1::TeamsController"  => %w(index update)}.each do |key, value|
        value.each do |action|
          role = create(:role, controller: key, action: action)
          create(:admin_role, admin_id: user.id, role_id: role.id)
        end
      end
    end
  end

end
