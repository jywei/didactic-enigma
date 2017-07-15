class AddIsParlayToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :is_parlay, :boolean
  end
end
