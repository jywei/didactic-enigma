namespace :worker do
  namespace :runner do
    task offer: :environment do
      Process.setproctitle "worker:runner:offer"
      Daemons.daemonize
      loop do
        t = Time.now
        Worker::Runner::Offer.run_once
        puts "#{(Time.now - t).round(3)}s"
        sleep Worker::Runner::Base.interval
      end
    end
  end
end

