class ChangeNameInRoles < ActiveRecord::Migration[5.0]
  def change
    rename_column :roles, :name, :controller
    rename_column :roles, :api, :action
  end
end
