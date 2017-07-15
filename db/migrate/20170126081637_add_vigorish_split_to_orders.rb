class AddVigorishSplitToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :vigorish_split, :boolean
  end
end
