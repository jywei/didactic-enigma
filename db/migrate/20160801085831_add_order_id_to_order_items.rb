class AddOrderIdToOrderItems < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :order_id, :integer

    add_index :order_items, :order_id
    add_index :order_items, :offer_id
    add_index :order_items, :match_id

    add_index :orders, :user_id
  end
end
