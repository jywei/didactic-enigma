namespace :worker do
  namespace :runner do
    task broadcast: :environment do
      Process.setproctitle "worker:runner:cable"
      Daemons.daemonize
      loop do
        Worker::Runner::Broadcast.run_once
        sleep Worker::Runner::Base.interval
      end
    end
  end
end


