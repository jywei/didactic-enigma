class AddOpposToPushLogs < ActiveRecord::Migration[5.0]
  def change
    add_column :push_logs, :h_oppo, :decimal, precision: 7, scale: 4
    add_column :push_logs, :a_oppo, :decimal, precision: 7, scale: 4
    add_column :push_logs, :d_oppo, :decimal, precision: 7, scale: 4
  end
end
