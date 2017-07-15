class DeleteTotalQuotaInUser < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :total_quota
  end
end
