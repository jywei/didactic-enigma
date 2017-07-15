class AddOtNameToPushLogs < ActiveRecord::Migration[5.0]
  def change
    add_column :push_logs, :ot_name, :string
  end
end
