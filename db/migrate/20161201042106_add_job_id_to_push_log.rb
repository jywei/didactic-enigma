class AddJobIdToPushLog < ActiveRecord::Migration[5.0]
  def change
    if not Log::Push.column_names.include?("cache_job_id")
      add_column(:log_pushes, :cache_job_id, :string)
      add_index :log_pushes, :cache_job_id
    end
  end
end
