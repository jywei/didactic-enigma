class RenamePushLogsToLogPushes < ActiveRecord::Migration[5.0]
  def change
    rename_table :push_logs, :log_pushes
  end
end
