class RemoveTypeFromOrders < ActiveRecord::Migration[5.0]
  def change
    remove_column :orders, :type
    add_column :orders, :type_flag, :string
  end
end
