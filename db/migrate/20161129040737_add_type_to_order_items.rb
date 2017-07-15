class AddTypeToOrderItems < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :type_flag, :string
  end
end
