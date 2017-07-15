class MoveColumndToOrderItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :order_items, :h_odd
    remove_column :order_items, :a_odd
    remove_column :order_items, :d_odd
    remove_column :order_items, :team
    remove_column :order_items, :is_asian

    add_column :order_items, :odd, :decimal
    add_column :order_items, :result_target, :string
  end
end
