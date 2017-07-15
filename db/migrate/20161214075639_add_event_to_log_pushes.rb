class AddEventToLogPushes < ActiveRecord::Migration[5.0]
  def change
    add_column :log_pushes, :event, :string
    add_index :log_pushes, :event
  end
end
