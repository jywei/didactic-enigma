namespace :worker do
  namespace :runner do
    task cache_d: :environment do
      loop do
        Worker::Runner::Cache.run_once
        sleep Worker::Runner::Base.interval
      end
    end
  end
end

