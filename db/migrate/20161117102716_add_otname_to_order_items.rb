class AddOtnameToOrderItems < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :offer_name, :string, null: false
  end
end
