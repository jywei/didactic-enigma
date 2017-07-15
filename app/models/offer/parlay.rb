# 串關的Offer
class Offer::Parlay < ApplicationRecord
  include ::Offer::Open::Builder
  extend ::Offer::Helper
  include ::Offer::Helper
  extend  Operation::Odd::Algorithm

  belongs_to :offer
  belongs_to :match, optional: true
  has_many :order_items, as: :offer

  delegate :is_running, to: :offer
  delegate :stat, to: :offer
  delegate :category, to: :offer

  class << self
    def transform_parlay(offer)
      p     = offer.parlay
      attrs = parlay(offer)
      p ? p.update!(attrs) : create!(attrs)

      # 算亞新盤的部分目前都移到Go專案
      if p
        return unless attrs = asian(offer, p.id)
        p.asian ? p.asian.update!(attrs) : create!(attrs)
      end
    end

    def parlay_water
      0.018
    end

    def parlay(offer)
      {
        offer_id: offer.id,
        name: offer.name,
        h_odd: oppo_to_odd(offer.h_oppo, parlay_water),
        a_odd: oppo_to_odd(offer.a_oppo, parlay_water),
        d_odd: oppo_to_odd(offer.d_oppo, parlay_water),
        handicapped_team: AsiaOffer.handicap_team(offer),
        head: offer.head,
        water: parlay_water,
        flag: offer.flag,
        type_flag: 'normal',
        match_id: offer.match_id
      }
    end

  #   算亞新盤的部分目前都移到Go專案
    def asian(offer, parlay_id)
      default_prob = AsiaOffer.get_default_prob($redis, "asia_prob")
      return if not AsiaOffer.asianable?(offer)
      return if not default_prob
      base_asia = AsiaOffer.convert_to_asia(offer, default_prob)
      return if base_asia.nil?
      base = base_asia.dig(:base)
      odd = 1 / (1 + parlay_water / 2)
      {
        offer_id: parlay_id,
        name: offer.name,
        h_odd: odd,
        a_odd: odd,
        handicapped_team: base.handicap_team,
        asian_head: base.asia_head,
        asian_proportion: base.standard_prob,
        water: parlay_water,
        flag: offer.flag,
        flat_head: base.flat_head.to_s,
        type_flag: 'asian'
      }
    end
  end

  def offer
    case type_flag
    when "normal"
      Offer.find(offer_id)
    when "asian"
      self.class.find_by(id: offer_id, type_flag: 'normal')
    end
  end

  def asian
    return nil if type_flag == "asian"
    self.class.find_by(offer_id: id, type_flag: 'asian')
  end

  def asia_format
    "#{asian_head}#{asian_proportion.to_f >= 0 ? "+#{asian_proportion.to_f}" : asian_proportion.to_f}"
  end
end
