class AddCurrentQuotaToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :current_quota, :integer
  end
end
