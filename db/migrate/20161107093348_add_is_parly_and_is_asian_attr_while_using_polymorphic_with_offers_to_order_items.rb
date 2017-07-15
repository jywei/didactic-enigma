class AddIsParlyAndIsAsianAttrWhileUsingPolymorphicWithOffersToOrderItems < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :is_parlay, :boolean
    add_column :order_items, :is_asian, :boolean
    add_column :order_items, :resource_name, :string
    add_column :order_items, :resource_id, :integer
    remove_column :order_items, :offer_id
  end
end
