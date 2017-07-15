class Worker::Runner::Log < Worker::Runner::Base
  queue_as :push_log

  def self.run(data)
    Log::Push.create!(data)
  end
end
