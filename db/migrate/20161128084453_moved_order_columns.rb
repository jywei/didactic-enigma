class MovedOrderColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :orders, :result
    remove_column :orders, :is_parlay

    add_column :orders, :settle, :boolean
  end
end
