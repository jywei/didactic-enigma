class Worker::Runner::Cache < Worker::Runner::Base
  queue_as :cache

  def self.run(data)
    ::Cache::Setter.new(data).run
  end
end
