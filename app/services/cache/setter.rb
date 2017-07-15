require "#{Rails.root}/app/services/operation/odd"

module Cache
  class Setter
    include Operation::Odd::Algorithm

    def initialize(options = {})
      @uuid      = options[:uuid]
      @action    = options[:action]
      @options   = options.except(:uuid)
      @match     = ::Match.find(@options[:match_id]) if match_id?
      @push_log  = ::Log::Push::Temp.new("cache", @uuid, @options)
      @push_log.push("Running job with option: #{options}")
      @push_log.push("Match is #{@match.try(:attributes)}")
    end

    def run
      @push_log.action(@action)
      if @action == 'open_match'
        afu_match = @match.open!
        @push_log.push("Match is opened as: #{@match.afu}")
        afu_match.broadcast_new_match
      elsif find_afu_match
        case @action
        when "assign_offer"
          assign_offer
        when "update_offer"
          update_offer
        when "replace_offer"
          replace_offer
        when "running"
          running
        end
      end
      # Worker::Runner::Log.run_by_env(@push_log.format) if @action == 'running'
      Worker::Runner::Log.run_by_env(@push_log.format)
    end



    # 由variant worker送過來的task
    def replace_offer
      Cache::Lock::Match.lock(@afu_match["match_id"]) do
        offer = ::Offer.find(@options[:offer_id])

        @push_log.push("===============進入replace_offer===============")
        # 算出亞新盤及串關盤回塞db
        # update_asian_and_update_parlay(offer)

        #這邊應該也可以用＠afu_match 
        afu_match = $redis.afu_match!(@match.redis_id)
        @push_log.push("[更動前的Match] #{afu_match}")
        @push_log.push("Current afu_match is with key: #{afu_match.key}")
        afu_match.assign!(offer, @options[:match_key])
        @push_log.push("Assigned: #{afu_match[:play][offer.name]}")
        Worker::Runner::Broadcast.run_by_env(channel: 'MatchesChannel', data: afu_match.new_head(offer.name, 'MatchesChannel'), uuid: @uuid)
        Worker::Runner::Broadcast.run_by_env(channel: 'Player::MatchesChannel', data: afu_match.new_head(offer.name, 'Player::MatchesChannel'), uuid: @uuid)
        @push_log.push("offer h_oppo: #{offer.h_oppo.to_f}, a_oppo: #{offer.a_oppo.to_f}")


        after_afu_match = $redis.afu_match!(@match.redis_id)
        @push_log.push("[更動後的Match] #{after_afu_match}")
        # if offer.h_oppo.to_f == 0.0 && offer.a_oppo.to_f == 0.0
        #   @push_log.push("Disabling offer for its oppo are 0.0")
        #   Worker::Runner::Broadcast.run_by_env(
        #     channel: 'MatchesChannel',
        #     data:    afu_match.offer_stat(offer: offer.name, stat:  'disabled'),
        #     uuid:    @uuid
        #   )
        #   Worker::Runner::Broadcast.run_by_env(
        #     channel: 'Player::MatchesChannel',
        #     data:    afu_match.offer_stat(offer: offer.name, stat:  'disabled'),
        #     uuid:    @uuid
        #   )
        # else
        #   @push_log.push("Offer is still on, not disabling.")
        # end
      end
    end

    def assign_offer
      Cache::Lock::Match.lock(@afu_match["match_id"]) do
        offer = ::Offer.find(@options[:offer_id])
        @push_log.push("===============進入assign_offer===============")
        @push_log.push("[更動前的Match] #{@afu_match}")

        # 算出亞新盤及串關盤回塞db
        # update_asian_and_update_parlay(offer)

        @push_log.push("Found offer with id #{@options[:offer_id]}: #{offer}")
        @push_log.push("Incoming match_key: #{@options[:match_key]}")
        @push_log.push("DB Match redis_id: #{@match.try(:redis_id)}")
        @push_log.push("Current afu_match is with key: #{@afu_match.key}")
        
        afu_offer = @afu_match.send(offer.name.to_sym)

        @push_log.push("Current afu_offer: #{afu_offer}")
        if afu_offer.available?
          @push_log.push("offer is already available. Updating offer instead.")
          update_offer
          return
        end
        @push_log.push("Assigning afu_offer")
        
        @afu_match.assign!(offer, @options[:match_key])


        # ===============
        find_afu_match
        @push_log.push("[更動後的Match] #{@afu_match}")
        # ===============

        
        @push_log.push("Requesting broadcast odd to MatchesChannel with: #{@afu_match.leader_offer_odds(offer.name)}")
        Worker::Runner::Broadcast.run_by_env(
          channel: 'MatchesChannel',
          data: @afu_match.leader_offer_odds(offer.name),
          uuid: @uuid
        )
        @push_log.push("Requesting broadcast odd to Player::MatchesChannel with: #{@afu_match.gamer_leader_offer_odd(offer.name, DateTime.mil)}")
        Worker::Runner::Broadcast.run_by_env(
          channel: 'Player::MatchesChannel',
          data: @afu_match.gamer_leader_offer_odd(offer.name, DateTime.mil),
          uuid: @uuid
        )
        stat = {
          action:           'stat',
          _match_id:        @afu_match[:_match_id],
          _halves_match_id: @afu_match[:_halves_match_id],
          match_id:         @afu_match[:match_id],
          offer:            offer.name,
          stat:             'normal'
        }
        @push_log.push("Requesting broadcast stat to both channels with: #{stat}")
        Worker::Runner::Broadcast.run_by_env(channel: 'MatchesChannel', data: stat, uuid: @uuid)
        Worker::Runner::Broadcast.run_by_env(channel: 'Player::MatchesChannel', data: stat, uuid: @uuid)
      end
    end

    def running
      Cache::Lock::Match.lock(@afu_match["match_id"]) do
        @push_log.push("===============進入running===============")
        @push_log.push("[更動前的Match] #{@afu_match}")



        offer = @afu_match.send(@options[:offer_name].to_sym)
        @push_log.push("afu_offer found: #{offer}")
        offer["is_running"] = true
        @afu_match["parlay"][offer["type"]]["is_running"] = true
        @afu_match["is_running"] = true
        %i(play parlay).each { |type| @afu_match[type].disable_unlive_offers(offer) }
        @push_log.push("afu_match before save: #{@afu_match}")

        @afu_match.save!
        
        # ===============
        find_afu_match
        @push_log.push("[更動後的Match] #{@afu_match}")
        # ===============

        @push_log.push("afu_match reloaded after save: #{afu_match_without_play_and_parlay}")
        @push_log.push("afu_offer reloaded after save: #{@afu_match.reload.send(@options[:offer_name].to_sym)}")
        hash = {
          action:         'match_live',
          _match_id:        @afu_match[:_match_id],
          _halves_match_id: @afu_match[:_halves_match_id],
          match_id:         @afu_match[:match_id]
        }
        Worker::Runner::Broadcast.run_by_env(channel: 'MatchesChannel', data: hash, uuid: @uuid)
        Worker::Runner::Broadcast.run_by_env(channel: 'Player::MatchesChannel', data: hash, uuid: @uuid)
      end
    end

    def update_offer
      Cache::Lock::Match.lock(@afu_match["match_id"]) do
        @push_log.push("===============進入update_offer===============")
        offer      = ::Offer.find(@options[:offer_id])

        # 算出亞新盤及串關盤回塞db
        # update_asian_and_update_parlay(offer)

        @afu_offer = @afu_match.send(:"#{offer.name}")
        @push_log.push("Found offer with id #{@options[:offer_id]}: #{offer}")
        @push_log.push("Incoming match_key: #{@options[:match_key]}")
        @push_log.push("DB Match redis_id: #{@match.try(:redis_id)}")
        @push_log.push("Current afu_match is with key: #{@afu_match.key}")
        @push_log.push("Current afu_offer: #{@afu_offer}")
        if @afu_offer.available?.!
          @push_log.push("offer is not available. Assigning offer instead.")
          assign_offer
          return
        end
        @push_log.push("Updating offer.")
        

        # ===============
        @push_log.push("[更動前的Match] #{@afu_match}")
        # ===============



        offer.sync_cache(@options.merge!(afu_match: @afu_match))

        # 無法判斷是否save!
        @afu_match.save!

        # ===============
        find_afu_match
        @push_log.push("[更動後的Match] #{@afu_match}")
        # ===============
        

        @push_log.push("Requesting broadcast stat to both channels with: #{@afu_match.offer_stat(offer: @afu_offer[:type], stat:  @afu_offer[:stat])}")
        @push_log.push("offer h_oppo: #{offer.h_oppo.to_f}, a_oppo: #{offer.a_oppo.to_f}")


        # 以下純廣播，不會都不會寫資料，只發broadcast task
        # 更改賠率時，先廣播狀態改變 [db及redis都沒操作]
        if @options[:stat_changed]
          stat_broadcast = @afu_match.offer_stat(offer: @afu_offer[:type], stat: @afu_offer[:stat])
          @push_log.push("Offer stat has changed, adding task to broadcast: #{stat_broadcast}")
          Worker::Runner::Broadcast.run_by_env(
            channel: 'MatchesChannel',
            data:    stat_broadcast,
            uuid:    @uuid
          )
          Worker::Runner::Broadcast.run_by_env(
            channel: 'Player::MatchesChannel',
            data:    stat_broadcast,
            uuid:    @uuid
          )
        # 如果送過來是00，代表這個玩法暫時停止 [db及redis都沒操作]
        elsif offer.h_oppo.to_f == 0.0 && offer.a_oppo.to_f == 0.0
          stat_broadcast = @afu_match.offer_stat(offer: @afu_offer[:type], stat: 'disabled')
          @push_log.push("Offer oppo are dead, adding task to broadcast: #{stat_broadcast}")
          Worker::Runner::Broadcast.run_by_env(
            channel: 'MatchesChannel',
            data:    stat_broadcast,
            uuid:    @uuid
          )
          Worker::Runner::Broadcast.run_by_env(
            channel: 'Player::MatchesChannel',
            data:    stat_broadcast,
            uuid:    @uuid
          )
        end

        # 如果是亞新盤，更新球頭，然後跑new_head廣播 [db及redis都沒操作]
        if updating_asian_offer?
          new_head = @afu_match.new_head(@afu_offer[:type], 'MatchesChannel')
          player_new_head = @afu_match.new_head(@afu_offer[:type], 'Player::MatchesChannel')

          @push_log.push("Requesting broadcast update_head to MatchesCahnnel with: #{new_head}")
          @push_log.push("Requesting broadcast update_head to Player::MatchesCahnnel with: #{new_head}")
          Worker::Runner::Broadcast.run_by_env(
            channel: 'MatchesChannel',
            data:    new_head,
            uuid:    @uuid
          )
          Worker::Runner::Broadcast.run_by_env(
            channel: 'Player::MatchesChannel',
            data:    player_new_head,
            uuid:    @uuid
          )
        # 如果是一般盤，就跑Serializer的leader_offer_odds(有base及modifier參數),gamer_leader_offer_odd(只有h跟a) [db及redis都沒操作]
        else
          @push_log.push("Requesting broadcast odd to MatchesChannel with: #{@afu_match.leader_offer_odds(@afu_offer[:type])}")
          @push_log.push("Requesting broadcast odd to Player::MatchesChannel with: #{@afu_match.gamer_leader_offer_odd(@afu_offer[:type], DateTime.mil)}")
          Worker::Runner::Broadcast.run_by_env(
            channel: 'MatchesChannel',
            data:    @afu_match.leader_offer_odds(@afu_offer[:type]),
            uuid:    @uuid
          )
          Worker::Runner::Broadcast.run_by_env(
            channel: 'Player::MatchesChannel',
            data:    @afu_match.gamer_leader_offer_odd(@afu_offer[:type], DateTime.mil),
            uuid:    @uuid
          )
        end
      end
    end

    def updating_asian_offer?
      @afu_offer[:asian_new] == true
    end

    def find_afu_match
      key = @options[:match_key].present? ? @options[:match_key] : @match.try(:redis_id)
      @afu_match = $redis.afu_match(key)
      @push_log.push("afu_match found: #{afu_match_without_play_and_parlay}")
      @afu_match
    end

    def match_id?
      @options[:match_id].present? && @options[:match_id] != 0
    end

    def afu_match_without_play_and_parlay
      if @afu_match
        n = @afu_match.reload.clone
        n.delete("play")
        n.delete("parlay")
        n
      end
    end

    protected

    def update_asian_and_update_parlay(offer)
      
      if offer.update_asia
        # binding.pry  
        @push_log.push("亞新盤更新成功！")
      else
        @push_log.push("亞新盤更新失敗..")
      end

      if offer.update_parlay
        @push_log.push("串關盤更新成功！")
      else
        @push_log.push("串關盤更新失敗..")
      end
    end

  end #class
end #module
