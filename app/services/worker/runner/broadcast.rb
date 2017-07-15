class Worker::Runner::Broadcast < Worker::Runner::Base
  queue_as :broadcast

  class << self
    def key
      "#{Rails.env}/worker/broadcast/lock"
    end

    def lock(index, value, &block)
      if not $redis.hget(key, index).eql? value
        block.call
        $redis.hset(key, index, value)
      end
    end

    def run(data)
      # d     = data[:data]
      # key   = "#{data[:channel]}/#{d[:match_id]}/#{d[:offer]}"
      # value = "#{d[:h_odd]}/#{d[:a_odd]}/#{d[:d_odd]}"
      # lock(key, value) do
        # For debugging push log
        data[:data].merge!(uuid: data[:uuid])

        # ===== Logging =====
        d = data[:data]
        match = Match.find_by(redis_id: d[:_halves_match_id])
        if match.present?
          begin
            # P=>要找出為什麼有時match.category.name 沒有cateogy / 80%
            logger.info("[worker/broadcast][#{match.leader_id}][#{match.redis_id}][#{match.category.name}][#{d[:action]}] #{Info::OddTypePush.type_to_ch(match.halves)}, 主隊：#{match.hteam.display_name}, 客隊：#{match.ateam.display_name}, 玩法：#{Info::OddTypePush.name_to_ch(d[:offer])}, 頭：#{d[:handicapped].try(:[], :head)}, 主：#{d[:h]}, 客：#{d[:a]}, 串關主：#{d[:parlay_h]}, 串關客：#{d[:parlay_a]}")  
          rescue Exception => e
            logger.info("[error and retry][worker/broadcast][leader_id=>#{match.leader_id}][redis_id=>#{match.redis_id}]")
            puts e
          end
        end
        # ==================

        ActionCable.server.broadcast(data[:channel], data[:data])
      # end
    end
  end
end
