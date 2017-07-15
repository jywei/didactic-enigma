class ChangeColumnNameInVigorishAncestors < ActiveRecord::Migration[5.0]
  def change
    rename_column :vigorish_ancestors, :order_id, :order_item_id
  end
end
