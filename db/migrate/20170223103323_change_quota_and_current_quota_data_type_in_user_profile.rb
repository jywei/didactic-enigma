class ChangeQuotaAndCurrentQuotaDataTypeInUserProfile < ActiveRecord::Migration[5.0]
  def change
    change_column :user_profiles, :quota, :decimal
    change_column :user_profiles, :current_quota, :decimal
  end
end
