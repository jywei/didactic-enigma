class AddIndexToPushLogAction < ActiveRecord::Migration[5.0]
  def change
    add_index :log_pushes, :action
  end
end
