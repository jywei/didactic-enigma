class AddTotalVigorishToVigorishAncestors < ActiveRecord::Migration[5.0]
  def change
    add_column :vigorish_ancestors, :total_vigorish, :decimal, precision: 12, scale: 3
  end
end
