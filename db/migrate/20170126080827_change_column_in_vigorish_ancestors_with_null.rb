class ChangeColumnInVigorishAncestorsWithNull < ActiveRecord::Migration[5.0]
  def change
    change_column :vigorish_ancestors, :order_item_id, :integer, null: true
  end
end
