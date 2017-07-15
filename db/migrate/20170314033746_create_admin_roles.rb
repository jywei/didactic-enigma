class CreateAdminRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :admin_roles do |t|
      t.integer :admin_id
      t.integer :role_id

      t.timestamps
    end
  end
end
