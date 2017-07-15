class ChangeDecimalTypeForItems < ActiveRecord::Migration[5.0]
  def change
    change_column :order_items, :h_odd, :decimal, scale: 4, precision: 6
    change_column :order_items, :a_odd, :decimal, scale: 4, precision: 6
    change_column :order_items, :d_odd, :decimal, scale: 4, precision: 6
  end
end
