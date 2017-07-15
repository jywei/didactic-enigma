class AddUserAncestorIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :user_ancestor_id, :integer, after: :id
  end
end
