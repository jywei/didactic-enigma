class AddAmountToOrderItem < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :amount, :integer, default: 0
  end
end
