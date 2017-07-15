class AddTargetToOrderItems < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :target, :string
  end
end
