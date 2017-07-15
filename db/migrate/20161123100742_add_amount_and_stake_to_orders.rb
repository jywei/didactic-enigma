class AddAmountAndStakeToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :stake, :integer
    remove_column :order_items, :amount
    remove_column :order_items, :stake
    remove_column :order_items, :is_parlay
  end
end
