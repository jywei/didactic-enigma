class ChangeDecimalPrecisionForQuotaAndCurrentQuota < ActiveRecord::Migration[5.0]
  def change
    change_column :user_profiles, :quota, :decimal, precision: 12, scale: 4
    change_column :user_profiles, :current_quota, :decimal, precision: 12, scale: 4
  end
end
