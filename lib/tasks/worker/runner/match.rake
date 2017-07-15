namespace :worker do
  namespace :runner do
    task match: :environment do
      # Process.setproctitle "worker:runner:match"
      Daemons.daemonize
      loop do
        Worker::Runner::Match.run_once
        sleep Worker::Runner::Base.interval
      end
    end
  end
end
