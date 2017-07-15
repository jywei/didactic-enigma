class MovedOrderMatchRelationship < ActiveRecord::Migration[5.0]
  def change
    remove_column :order_items, :match_id
    add_column    :orders, :match_id, :integer
  end
end
