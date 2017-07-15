namespace :worker do
  namespace :runner do
    task variant_offer: :environment do
      Process.setproctitle "worker:runner:variant_offer"
      Daemons.daemonize
      loop do
        Worker::Runner::VariantOffer.run_once
        sleep Worker::Runner::Base.interval
      end
    end
  end
end

