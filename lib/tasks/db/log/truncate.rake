namespace :db do
  namespace :log do
    task truncate: :environment do
      # Log::Push.where("created_at < ?", Time.now - 5.days).delete_all
      # Log::Error.where("created_at < ?", Time.now - 7.days).delete_all
      ActiveRecord::Base.connection.execute("TRUNCATE `log_pushes`")
    end
  end
end
