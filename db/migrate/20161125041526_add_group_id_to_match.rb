class AddGroupIdToMatch < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :group_id, :integer
  end
end
