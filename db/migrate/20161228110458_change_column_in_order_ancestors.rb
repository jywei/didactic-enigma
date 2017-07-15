class ChangeColumnInOrderAncestors < ActiveRecord::Migration[5.0]
  def change
    change_column :order_ancestors, :member, :decimal, precision: 12, scale: 3
    change_column :order_ancestors, :agent, :decimal, precision: 12, scale: 3
    change_column :order_ancestors, :general_agent, :decimal, precision: 12, scale: 3
    change_column :order_ancestors, :shareholder, :decimal, precision: 12, scale: 3
    change_column :order_ancestors, :major_shareholder, :decimal, precision: 12, scale: 3
    change_column :order_ancestors, :director, :decimal, precision: 12, scale: 3
    change_column :order_ancestors, :supervisor, :decimal, precision: 12, scale: 3
    change_column :order_ancestors, :moderator, :decimal, precision: 12, scale: 3
    change_column :order_ancestors, :admin, :decimal, precision: 12, scale: 3
  end
end
