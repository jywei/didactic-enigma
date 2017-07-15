class CreateUserSetting < ActiveRecord::Migration[5.0]
  def change
    create_table :user_settings, force: true do |t|
      t.integer :sport_id
      t.integer :user_id
      t.integer :rebate, default: 0
      t.integer :offer_quota, default: 0
      t.integer :match_quota, default: 0

      t.timestamps
    end

    create_table :user_allotters, force: true do |t|
      t.integer :sport_id
      t.integer :user_id
      t.decimal :oppo, precision: 7, scale: 4, default: 0.0

      t.timestamps
    end
  end
end
