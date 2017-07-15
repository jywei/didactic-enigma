class AddSplitToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :split, :boolean
  end
end
