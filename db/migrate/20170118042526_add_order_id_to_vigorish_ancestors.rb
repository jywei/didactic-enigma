class AddOrderIdToVigorishAncestors < ActiveRecord::Migration[5.0]
  def change
    add_column :vigorish_ancestors, :order_id, :integer
  end
end
