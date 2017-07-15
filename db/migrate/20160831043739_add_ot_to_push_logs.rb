class AddOtToPushLogs < ActiveRecord::Migration[5.0]
  def change
    add_column :push_logs, :ot, :integer
    add_column :push_logs, :head, :decimal, precision: 7, scale: 4
    rename_column :push_logs, :type, :ot_type
  end
end
