class AddQuotaToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :total_quota, :integer, default: 0
  end
end
