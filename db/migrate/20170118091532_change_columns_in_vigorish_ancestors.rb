class ChangeColumnsInVigorishAncestors < ActiveRecord::Migration[5.0]
  def change
    change_column :vigorish_ancestors, :member, :decimal, precision: 12, scale: 3
    change_column :vigorish_ancestors, :agent, :decimal, precision: 12, scale: 3
    change_column :vigorish_ancestors, :general_agent, :decimal, precision: 12, scale: 3
    change_column :vigorish_ancestors, :shareholder, :decimal, precision: 12, scale: 3
    change_column :vigorish_ancestors, :major_shareholder, :decimal, precision: 12, scale: 3
    change_column :vigorish_ancestors, :director, :decimal, precision: 12, scale: 3
    change_column :vigorish_ancestors, :supervisor, :decimal, precision: 12, scale: 3
    change_column :vigorish_ancestors, :moderator, :decimal, precision: 12, scale: 3
    change_column :vigorish_ancestors, :admin, :decimal, precision: 12, scale: 3
  end
end
