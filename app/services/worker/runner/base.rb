class Worker::Runner::Base
  class << self
    attr_accessor :queue

    def logger
      @logger ||= Logger.new("#{Rails.root}/log/#{Rails.env}.log")
    end

    def queue_as(name)
      self.queue = "worker/#{name}"
    end

    def queue_name
      self.queue
    end

    def interval
      0.0001
    end

    def enqueue(data)
      logger.info("[#{queue_name}] Enqueuing: #{data}")
      $worker.rpush(queue_name, data.to_json)
    end

    def update_timestamp(init_time = Time.now)
      t = Time.now
      m = (t.to_f % 1).round(6)
      $worker.set("#{queue_name}/timestamp", t.strftime("%Y-%m-%d %H:%M:%S:#{m}"))
      $worker.set("#{queue_name}/processing_time", t - init_time)
    end

    def logging(&block)
      # log = Log::Push::Temp.new(action_name: self.name)
      init_time = Time.now
      block.call
      update_timestamp(init_time)
      # Worker::Runner::Log.run_by_env(log) unless self == Worker::Runner::Log
    end

    def run_once
      data = $worker.lpop(queue_name)
      return if data.blank?
      parsed_data = JSON.parse(data).with_indifferent_access
      logger.info("[#{queue_name}] Running: #{parsed_data}")
      run_now(parsed_data)
    rescue => e
      log_to_error(e, parsed_data)
    end

    def run_now(data)
      logging { run(data) }
    end

    def run_by_env(data)
      case Rails.env
      when 'development', 'production'
        enqueue(data)
      when 'test'
        run_now(data)
      end
    end

    def log_to_error(e, data)
      ::Log::Error.create!(
        name:      e.class.name,
        message:   e.message,
        path:      queue_name,
        backtrace: e.backtrace,
        params:    data
      )
      logger.error("[#{queue_name}] #{e.class} #{e.message}\n#{e.backtrace[0..2]}")
    end

  end
end
