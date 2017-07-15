class AddTimestampToLogPush < ActiveRecord::Migration[5.0]
  def change
    add_column :log_pushes, :tx_timestamp, :integer
  end
end
