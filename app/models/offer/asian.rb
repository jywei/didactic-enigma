# 亞新盤玩法
class Offer::Asian < ApplicationRecord
  belongs_to :offer, dependent: :destroy
  has_many :order_items, as: :offer

  delegate :series,     to: :offer
  delegate :match,      to: :offer
  delegate :is_running, to: :offer
  delegate :stat,       to: :offer
  delegate :category,   to: :offer

  include ::Offer::Helper

  class << self
    def transform_asia(offer)
      default_prob = AsiaOffer.get_default_prob($redis, "asia_prob")
      return if default_prob.blank?
      base_asia = if Rails.env.test?
                    AsiaOffer.convert_to_asia_with_head(offer, default_prob, offer.test_flat_head)
                  else
                    AsiaOffer.convert_to_asia(offer, default_prob)
                  end
      return if base_asia.nil?
      format_asia = convert_format(base_asia)
      a = offer.reload.asian
      a ? a.update!(format_asia) : create!(format_asia)
    end

    def convert_format(offer)
      base = offer.dig(:base)
      asia = offer.dig(:asia)
      {
        name: base.name,
        offer_id: base.id,
        h_odd: 0.95,
        a_odd: 0.95,
        asian_proportion: base.standard_prob,
        asian_head: base.asia_head,
        handicapped_team: base.handicap_team,
        asia_format: asia.dig(:asia_format, :standard),
        orgin_asia_format: asia.dig(:origin_format),
        water: 0.01,
        flat_head: base.flat_head.to_s
      }
    end
  end

  # Offer::Asian 就不會再有亞新盤了所以回傳 nil，你有聽過黑人版的丹佐華盛頓嗎他本來就黑人了廢話
  def asian
    nil
  end

end
