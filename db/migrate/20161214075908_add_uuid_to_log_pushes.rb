class AddUuidToLogPushes < ActiveRecord::Migration[5.0]
  def change
    add_column :log_pushes, :uuid, :string
    add_index :log_pushes, :uuid
  end
end
