module Cache
  class Lock
    class Match
      def self.lock(id, &block)
        raise "Invalid lock id `#{id}`(#{id.class}). Use either String or Integer." if id.blank?
        lock!(id)
        begin
          block.call
        rescue => e
          unlock!(id)
          raise e
        end
        unlock!(id)
      end

      def self.all
        $redis.hgetall($matches_lock).keys
      end

      def self.unlock!(id)
        $redis.hdel($matches_lock, id.to_s)
      end

      def self.lock!(id)
        if id.blank?
          raise "Invalid lock id `#{id}`(#{id.class}). Use either String or Integer."
        end
        i = 0
        loop do
          if i > 10
            unlock!(id)
          end
          if $redis.hsetnx($matches_lock, id.to_s, 0)
            break
          end
          i += 1
          sleep 0.1
        end
      end

      def self.lock?(id)
        all.include?(id.to_s)
      end
    end
  end
end
