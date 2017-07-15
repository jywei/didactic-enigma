class AddIndexToGroupIdInMatch < ActiveRecord::Migration[5.0]
  def change
    add_index :matches, :group_id
  end
end
