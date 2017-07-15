class ChangeOrderItemsOdd < ActiveRecord::Migration[5.0]
  def change
    change_column :order_items, :odd, :decimal, precision: 7, scale: 4, default: 0.0
  end
end
