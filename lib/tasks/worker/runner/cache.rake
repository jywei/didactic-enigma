namespace :worker do
  namespace :runner do
    task cache: :environment do
      Process.setproctitle "worker:runner:cache"
      Daemons.daemonize
      loop do
        Worker::Runner::Cache.run_once
        sleep Worker::Runner::Base.interval
      end
    end
  end
end

