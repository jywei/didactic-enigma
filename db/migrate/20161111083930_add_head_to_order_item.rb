class AddHeadToOrderItem < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :head, :decimal, precision: 6, scale: 3
    add_column :order_items, :proportion, :integer
  end
end
