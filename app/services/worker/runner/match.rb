class Worker::Runner::Match < Worker::Runner::Base
  queue_as :push_match

  def self.run(data)
    Operation::Odd::Match.new(data).create
  end
end
