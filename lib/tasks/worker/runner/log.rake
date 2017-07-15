namespace :worker do
  namespace :runner do
    task log: :environment do
      Process.setproctitle "worker:runner:log"
      Daemons.daemonize
      loop do
        Worker::Runner::Log.run_once
        sleep Worker::Runner::Base.interval
      end
    end
  end
end
