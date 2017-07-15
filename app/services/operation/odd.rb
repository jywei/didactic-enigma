require 'colorize'

require_relative './odd/helpers'
require_relative './odd/conditions'
# require_relative './odd/tx'
# require_relative './odd/match'
# require_relative './odd/offer'
require_relative '../cache/lock'

module Operation
  class Odd
    include Helpers
    include Conditions
    # include Tx

    # 傳入參數：
    # args = {
    #   :code=>1,
    #   :msg=>"Update Odd",
    #   :match_id=>3821311,
    #   :offer_id=>"1080136126006+0.0",
    #   :h_oppo=>0.4935,
    #   :a_oppo=>0.5065,
    #   :d_oppo=>nil,
    #   :sport_id=>1,
    #   :offer_flags=>1,
    #   :last_updated=>"2016-11-07 10:50:57",
    #   :is_running=>0,
    #   :ts=>"123454657"
    # }
    def initialize(args, uuid = SecureRandom.uuid)
      @args      = args
      @leader    = 'tx'
      @push_log  = ::Log::Push::Temp.new("offer", uuid, @args)
      @operation = Operation::Odd::Offer.new(@args, @leader, @push_log)
    end

    def operate!
      begin
        process
      rescue => e
        @push_log.error(e)
        Worker::Runner::Log.run_by_env(@push_log.format)
        raise e
      end
      Worker::Runner::Log.run_by_env(@push_log.format)
    end

    def process
      return unless tx_valid?
      @push_log.push("Incoming tx ot: #{tx_offer[:otname]}")
      unless Rails.env.test?
        ActionCable.server.config.logger.info("[#{@args[:match_id]}] Incoming push: #{@args.to_s} (uuid: '#{@push_log.uuid}')")
      end

      offer = if db_offer_same_head
                o = @operation.update_db_odd_and_stat.reload
                if not Rails.env.test?
                  match = o.match
                  if match
                    ActionCable.server.config.logger.info("[#{@args[:match_id]}][#{match.key}][更新賠率][#{match.category.name}] #{Info::OddTypePush.type_to_ch(match.halves)}, 主隊：#{match.hteam.display_name}, 客隊：#{match.ateam.display_name}, 玩法：#{Info::OddTypePush.name_to_ch(db_offer_same_head.name)}, 頭：#{o.head.to_f}, 主：#{o.h_odd.to_f}, 客：#{o.a_odd.to_f}")
                  end
                end
                o
              else
                @operation.create_new.reload
              end

      case @operation.action
      when :update
        if offer.replaceable?
          worker_find_variants(offer)
        else
          hash = {
            action:       'update_offer',
            offer_id:     offer.id,
            match_id:     offer.match_id,
            tx_match_id:  @args[:match_id],
            is_running:   @args[:is_running],
            last_updated: @args[:last_updated],
            stat_changed: @operation.stat_changed?,
            uuid:         @push_log.uuid
          }
          @push_log.request('cache', hash)
          Worker::Runner::Cache.run_by_env(hash)
        end
        if @args[:is_running].to_s == "1"
          @push_log.request('running', @args)
          Operation::Odd::Running.new(@args, @push_log.uuid).update_running_ball
        end
      when :create
        if db_offers.size > 1
          worker_find_variants(offer)
        else
          hash = {
            action:      'assign_offer',
            offer_id:    offer.id,
            match_id:    offer.match_id,
            tx_match_id: @args[:match_id],
            uuid:        @push_log.uuid
          }
          @push_log.request("cache", hash)
          Worker::Runner::Cache.run_by_env(hash)
        end
      end
    end

    def worker_find_variants(offer)
      attrs = {
        offer_id:     offer.id,
        is_running:   @args[:is_running],
        last_updated: @args[:last_updated],
        stat_changed: @operation.stat_changed?,
        tx_match_id:  @args[:match_id],
        uuid:         @push_log.uuid
      }
      @push_log.request("variant_offers", attrs)
      Worker::Runner::VariantOffer.run_by_env(attrs)
    end

  end
end
