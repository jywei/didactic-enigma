class AddVigorishSplitToOrderItems < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :vigorish_split, :boolean
  end
end
