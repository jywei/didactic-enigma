require_relative './match'

module Cache
  class Server
    include Cache::Match

    def initialize
      redis_config = Rails.application.config.database_configuration[Rails.env || 'development']['redis']
      if redis_config.nil?
        raise "Redis server config not found. Make sure you have set #{Rails.env} -> redis -> server > host in database.yml"
      end
      cache_config = redis_config['server']
      if cache_config.nil?
        raise "Redis server config not found. Make sure you have set #{Rails.env} -> redis -> server > host in database.yml"
      end
      @db = Redis.new(
        host: cache_config['host'],
        port: cache_config['port']
      )
    end

    attr_reader :db

    def method_missing(method, *args)
      db.send(method.to_sym, *args)
    end

    def tx_match(match_id)
      tx_match_keys.each do |k|
        if m = $redis.hget(k, match_id.to_s)
          return JSON.parse(m).with_indifferent_access
        end
      end
      nil
    end

    def tx_matches_from(date)
      hgetall("tx_matches:#{date}")
    end

    def tx_matches(date, args = {})
      matches = hgetall("tx_matches:#{date}")
      if args[:mgid]
        matches.select! do |_k, v|
          JSON.parse(v).with_indifferent_access[:mgid].to_s == args[:mgid].to_s
        end
      end
      if matches.any?
        matches.each_with_object({}) do |match, result|
          result[match[0]] = JSON.parse(match[1]).with_indifferent_access
        end
      end
    end

    def tx_offer(offer_id)
      tx_offer_keys.each do |k|
        if m = $redis.hget(k, offer_id.to_s)
          return JSON.parse(m).with_indifferent_access
        end
      end
      nil
    end

    def tx_offers
      result = {}
      tx_offer_keys.each do |key|
        result.merge! $redis.hgetall(key)
      end
      result
    end

    def tx_match_keys
      $redis.keys.select { |n| n.include?('tx_matches:') }
    end

    def tx_offer_keys
      $redis.keys.select { |n| n.include?('tx_offers:') }
    end
  end
end
