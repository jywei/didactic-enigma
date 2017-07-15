module Operation
  class Odd
    module Conditions
      def exact_same_offer?
        db_match && db_offers? && db_offer_same_head?
      end

      def variant_offer?
        db_match && db_offers? && db_offer_variant?
      end

      def unavailable_offer?
        db_match && no_db_offer?
      end

      def db_offers?
        db_offers.any?
      end

      def db_offer_same_head?
        db_offers.find_by(head: tx_offer[:head].to_f)
      end

      def db_offer_variant?
        db_offer_same_head?.!
      end

      def no_db_offer?
        db_offers.any?.!
      end
    end
  end
end
