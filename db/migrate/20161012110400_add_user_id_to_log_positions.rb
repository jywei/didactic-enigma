class AddUserIdToLogPositions < ActiveRecord::Migration[5.0]
  def change
    add_column :log_positions, :user_id, :integer
  end
end
