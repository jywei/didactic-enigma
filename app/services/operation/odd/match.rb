module Operation
  class Odd
    class Match
      def initialize(attrs = nil, leader = 'tx')
        @uuid     = attrs[:uuid]
        @attrs    = attrs.except(:uuid)
        @leader   = leader
        @push_log = ::Log::Push::Temp.new("match", @uuid, @attrs)
        @push_log[:tx_match_id] = @attrs[:leader_id]
      end

      def create
        if match = ::Match.find_by(@attrs.keep('leader_id', 'halves', 'book_maker_id'))
          @push_log.push("Match already existed with ID ##{match.id}")
          @push_log.action("drop")
          return
        end
        @push_log.action("create")
        match = ::Match.new(@attrs)
        match.redis_id = match.key
        @push_log.push("Creating match with #{@attrs}")
        begin
          match.save!
          @push_log.push("Match created!")
        rescue => e
          @push_log.push("#{e.class} #{e.message}")
          @push_log.push("Looking for existing match.")
          if db_match
            @push_log.action("update")
            @push_log.push("Match exists: #{db_match}")
            return
          end
          raise e if Rails.env.test?
        end

        # link related offers under same tx_match
        offers = ::Offer.where(
          halves:          match.halves,
          book_maker_id:   match.book_maker_id,
          match_leader_id: match.leader_id
        )
        @push_log.push("Linking offers with id: #{offers.ids.join(",")}")
        offers.update_all(match_id: match.id)
        parlays = ::Offer::Parlay.where(offer_id: offers.ids)
        @push_log.push("Linking parlays with id: #{parlays.ids.join(",")}")
        parlays.update_all(match_id: match.id)

        data = {
          action: 'open_match',
          match_id: match.id,
          uuid: @uuid
        }
        @push_log.request('cache', data)
        Worker::Runner::Cache.run_by_env(data)

        Worker::Runner::Log.run_by_env(@push_log.format)
      end

      def db_match
        ::Match.find_by(
          leader_id: @attrs[:leader_id],
          halves: @attrs[:halves],
          book_maker_id: @attrs[:book_maker_id]
        )
      end
    end
  end
end
