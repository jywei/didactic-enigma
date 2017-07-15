namespace :resque do
  task push_log: :environment do
    loop do
      job = Resque.pop(:push_log)
      if job
        attributes = job["args"][0]["arguments"][0].except("_aj_symbol_keys") 
        Log::Push.create!(attributes)
      else
        sleep 0.5
      end
    end
  end
end
