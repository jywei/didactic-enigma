module Worker
  class Runner
    attr_reader :db

    def initialize
      redis_config  = Rails.application.config.database_configuration[Rails.env || 'development']['redis']
      if redis_config.nil?
        raise "Redis server config not found. Make sure you have set #{Rails.env} -> redis -> resque > host in database.yml"
      end
      worker_config = redis_config['server']
      if worker_config.nil?
        raise "Redis server config not found. Make sure you have set #{Rails.env} -> redis -> resque > host in database.yml"
      end
      @db = Redis.new(
        host: worker_config['host'],
        port: worker_config['port']
      )
    end

    delegate :lpop, :rpush, :llen, :keys, :del, :get, :set, to: :db
  end
end

require_relative './runner/base'
require_relative './runner/match'
require_relative './runner/offer'
require_relative './runner/cache'
require_relative './runner/variant_offer'
require_relative './runner/log'
require_relative './runner/broadcast'
