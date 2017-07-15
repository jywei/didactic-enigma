class AddNameAndDescriptionToRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :roles, :name, :string, :after => :id
    add_column :roles, :description, :string, :after => :action
  end
end
