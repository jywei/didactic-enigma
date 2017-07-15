class AddOtIdToOrderItems < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :ot_id, :integer
  end
end
