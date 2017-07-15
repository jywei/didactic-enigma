class Worker::Runner::Offer < Worker::Runner::Base
  queue_as :push_offer

  def self.run(data)
    Operation::Odd.new(data).operate!
  end
end

