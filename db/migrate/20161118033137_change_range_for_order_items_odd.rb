class ChangeRangeForOrderItemsOdd < ActiveRecord::Migration[5.0]
  def change
    change_column :order_items, :h_odd, :decimal, precision: 7, scale: 4
    change_column :order_items, :a_odd, :decimal, precision: 7, scale: 4
    change_column :order_items, :d_odd, :decimal, precision: 7, scale: 4
  end
end
