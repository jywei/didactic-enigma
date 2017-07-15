class ChangePolymorphicColumnNamesInOrderItem < ActiveRecord::Migration[5.0]
  def change
    rename_column :order_items, :resource_name, :offer_type
    rename_column :order_items, :resource_id, :offer_id
  end
end
