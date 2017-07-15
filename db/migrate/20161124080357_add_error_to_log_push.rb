class AddErrorToLogPush < ActiveRecord::Migration[5.0]
  def change
    add_column :log_pushes, :has_error, :boolean, default: false
    add_index :log_pushes, :has_error
  end
end
