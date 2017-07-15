class AddCategoryIdToOrderItems < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :category_id, :integer
  end
end
