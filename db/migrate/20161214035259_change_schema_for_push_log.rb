class ChangeSchemaForPushLog < ActiveRecord::Migration[5.0]
  def change
    remove_column :log_pushes, :log_start
    remove_column :log_pushes, :log_duration
    remove_column :log_pushes, :cache_job_id
  end
end
