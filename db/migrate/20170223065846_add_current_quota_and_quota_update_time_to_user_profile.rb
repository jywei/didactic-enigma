class AddCurrentQuotaAndQuotaUpdateTimeToUserProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :user_profiles, :current_quota, :decimal
    add_column :user_profiles, :quota_update_time, :string
  end
end
