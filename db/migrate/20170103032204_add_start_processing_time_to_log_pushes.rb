class AddStartProcessingTimeToLogPushes < ActiveRecord::Migration[5.0]
  def change
    add_column :log_pushes, :afu_timestamp, :string
  end
end
