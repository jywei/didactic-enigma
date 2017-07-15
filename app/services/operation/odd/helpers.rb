module Operation
  class Odd
    module Helpers
      def afu_water
        @afu_water ||= 0.015
      end

      def find_record_in(model, attr, value)
        if result = model.find_by(attr => value)
          result
        else
          raise(ActiveRecord::RecordNotFound, "#{model} with #{attr}: #{value} not found.")
        end
      end

      def offer_ot_type
        @offer_ot_type ||= Info::OddTypePush.type(tx_offer[:ot_id])
      end

      def offer_ot_type_id
        @offer_ot_type_id ||= Info::OddTypePush.type_to_i(offer_ot_type)
      end

      def offer_ot_name
        return @offer_ot_name if @offer_ot_name
        @offer_ot_name = Info::OddTypePush.name(tx_offer[:ot_id], tx_offer[:head], @args[:sport_id])
      end

      def afu_ref_key
        @afu_ref_key ||= "#{Time.parse(tx_match[:start_time]).in_time_zone('Asia/Taipei').strftime('%m%d%H%M')}_#{tx_offer[:match_id]}_#{book_maker.id}_#{Info::OddTypePush.ot_id_to_index(tx_offer[:ot_id])}"
      end

      def tx_match
        @tx_match ||= $redis.tx_match(@args[:match_id])
      end

      def tx_offer
        @tx_offer ||= $redis.tx_offer(@args[:offer_id])
      end

      def hteam
        @hteam ||= Team.find_by(tx_id: tx_match[:hteam_id]) ||
          Team.create(tx_id: tx_match[:hteam_id], name: tx_match[:hteam], category_id: category.id)
      end

      def ateam
        @ateam ||= Team.find_by(tx_id: tx_match[:ateam_id]) ||
          Team.create(tx_id: tx_match[:ateam_id], name: tx_match[:ateam], category_id: category.id)
      end

      def category
        @category ||= find_record_in(Category, :mgid, tx_match[:mgid])
      end

      def sport
        @sport ||= find_record_in(Sport, :spid, @args[:sport_id])
      end

      def book_maker
        @book_maker ||= find_record_in(BookMaker, :tx_id, tx_offer[:bid])
      end

      def afu_match
        return @afu_match if @afu_match
        if match = $redis.afu_match(afu_ref_key)
          @afu_match = match
        elsif afu_db_match
          @push_log.push("Afu match ##{afu_db_match.id} is found in db but not in redis. Opening...")
          @afu_match = afu_db_match.open!
          @push_log.push("Afu match ##{afu_db_match.id} is now in redis: #{$redis.afu_match(afu_ref_key, simple: true)}")
          @afu_match
        end
      end

      def db_match
        @db_match ||= ::Match.find_by(
          leader_id:     tx_offer[:match_id],
          halves:        offer_ot_type,
          book_maker_id: book_maker.id
        )
      end

      def necessary_match_attributes
        group = Group.find_or_create_by(category_id: category.id, tx_name: tx_offer[:group_name_ch]) do |g|
            g.display_name = tx_offer[:group_name_ch]
          end
        group_id = group.id
        {
          leader:        @leader,
          leader_id:     tx_offer[:match_id],
          start_time:    Time.parse(tx_match[:start_time]).in_time_zone('Asia/Taipei'),
          hteam_id:      hteam.id,
          ateam_id:      ateam.id,
          category_id:   category.id,
          halves:        offer_ot_type,
          book_maker_id: book_maker.id,
          active:        true,
          group_id:      group_id
        }
      end

      def afu_db_match
        @afu_db_match ||= ::Match.find_by(
          leader: @leader,
          leader_id: tx_offer[:match_id],
          halves: offer_ot_type,
          book_maker_id: book_maker.id
        )
      end

      def afu_offer
        @afu_offer ||= afu_match.try(:[], :play).try(:[], offer_ot_name.to_sym)
      end

      def db_offer_same_heads
        ::Offer.where(
          name: offer_ot_name,
          book_maker_id: book_maker.id,
          match_leader_id: tx_offer[:match_id],
          halves: offer_ot_type,
          head: tx_offer[:head].to_f
        )
      end

      def db_offer_same_head
        @db_offer_same_head ||= db_offer_same_heads.first
      end

      def db_offers
        @db_offers ||= ::Offer.where(
          name:          offer_ot_name,
          halves:        offer_ot_type,
          book_maker_id: book_maker.id,
          match_leader_id: tx_offer[:match_id]
        )
      end

      def db_offer
        @db_offer ||= db_offers.first
      end

      def create_offer(match_id = nil, save = true, flat = true)
        hash = {
          name:       offer_ot_name,
          h_odd:      oppo_to_odd(@args[:h_oppo]),
          a_odd:      oppo_to_odd(@args[:a_oppo]),
          d_odd:      oppo_to_odd(@args[:d_oppo]),
          head:       tx_offer[:head],
          leader:     @leader,
          leader_id:  @args[:offer_id],
          h_oppo:     @args[:h_oppo],
          a_oppo:     @args[:a_oppo],
          d_oppo:     @args[:d_oppo],
          flag:       @args[:offer_flags],
          water:      afu_water,
          match_id:   match_id,
          stat:       'normal',
          leader_timestamp: @args[:ts],
          flat:       flat,
          book_maker: book_maker,
          halves:     offer_ot_type,
          match_leader_id: tx_offer[:match_id],
          category_id: category.id,
        }
        @push_log.push("Creating offer: #{hash[:name]} with head #{hash[:head]} - #{hash}")
        offer = ::Offer.new(hash)
        begin
          if save
            offer.save!
            offer.update_asia
            offer.update_parlay
          end
          @push_log.push("New offer created ##{offer[:id]}")
        rescue => e
          @push_log.push("Error creating offer!")
          raise e
        end
        offer
      end
    end
  end
end
