namespace :resque do
  task push_log: :environment do
    i = 0
    loop do
      job = Resque.pop(:push_log)
      if job
        attributes = job["args"][0]["arguments"][0].except("_aj_symbol_keys") 
        PushLogJob.perform_now(attributes)
        print "Job processed: #{i}\r"
        i += 1
      else
        sleep 0.5
      end
    end
  end
end
