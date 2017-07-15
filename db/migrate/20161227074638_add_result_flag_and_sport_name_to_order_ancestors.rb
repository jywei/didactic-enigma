class AddResultFlagAndSportNameToOrderAncestors < ActiveRecord::Migration[5.0]
  def change
    add_column :order_ancestors, :result_flag, :string
    add_column :order_ancestors, :sport_name, :string
  end
end
