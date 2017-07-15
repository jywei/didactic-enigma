class AddMemberToUserAncestors < ActiveRecord::Migration[5.0]
  def change
    add_column :user_ancestors, :member, :integer, after: :user_id
  end
end
