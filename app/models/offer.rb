# Offer 儲存所有玩法，包含賠率，一般來說附屬於 Match 底下，由push feed產生
class Offer < ApplicationRecord
  include Open::Builder
  include ::Offer::Helper
  include Operation::Odd::Algorithm

  belongs_to :match, optional: true
  belongs_to :category, optional: true
  belongs_to :offer_position, optional: true
  belongs_to :book_maker
  has_one :setting, class_name: 'Offer::Setting', foreign_key: :offer_id, dependent: :destroy
  has_many :push_logs, class_name: 'Log::Push', foreign_key: :tx_offer_id, primary_key: :leader_id
  has_many :order_items, as: :offer
  has_one :asian, class_name: 'Offer::Asian', primary_key: :id, foreign_key: :offer_id, dependent: :destroy
  has_one :parlay,  class_name: 'Offer::Parlay', primary_key: :id, foreign_key: :offer_id, dependent: :destroy

  serialize :incoming_request, Hash

  validates :name, presence: true

  before_save :set_handicapped_team

  # for testing asian in test/services/asia_offer_test.rb
  attr_accessor :test_flat_head

  def set_handicapped_team
    self.handicapped_team = AsiaOffer.handicap_team(self)
  end

  # 找到集合內最平的球頭
  #
  # ```ruby
  # Offer.where(match_id: 1234).flat("point")
  # # => #<Offer:0x007fd92f3ac4c8>
  # ```
  def self.flat(ot_name)
    where(name: ot_name).to_a.sort { |a, b| a.oppo_diff <=> b.oppo_diff }.first
  end

  def self.name_and_flat
    ids = all.ids
    offers = all.to_a.sort { |a, b| [a.name, a.oppo_diff] <=> [b.name, b.oppo_diff] }
    asians  = Offer::Asian.where(offer_id: ids).to_a
    parlays = Offer::Parlay.where(offer_id: ids).to_a
    offers.map! do |o|
      o.attributes.with_indifferent_access.merge!(
        asian:  asians.select {|n| n[:offer_id] == o[:id] }.first,
        parlay: parlays.select {|n| n[:offer_id] == o[:id] }.first,
        oppo_diff: o.oppo_diff.round(3)
      )
    end

    offers.map {|o| o[:name] }.uniq.map! do |name|
      {
        name: name,
        offers: offers.select {|o| o[:name] == name }
      }
    end
  end

  def oppo_diff
    (h_oppo.to_f - a_oppo.to_f).abs
  end

  def update_asia
    Offer::Asian.transform_asia(self) if AsiaOffer.asianable?(self)
  end

  def update_parlay
    Offer::Parlay.transform_parlay(self)
  end

  def replaceable?
    match_id && Info::OddTypePush.multi_heads?(name)
  end

  def siblings
    query = if match_id
              { match_id: match_id }
            else
              {
                halves:          halves,
                match_leader_id: match_leader_id,
                book_maker_id:   book_maker_id
              }
            end
    self.class.where(query)
  end

  # 更新redis當中代表這個 Offer 的 Offer::Open 並儲存
  #
  # 參數：
  #
  #     {
  #       afu_match: Match::Open,
  #       is_running: Boolean,
  #       last_updated: String,
  #       stat_changed: Boolean
  #     }
  #
  def sync_cache(options = {})
    afu_match = if options[:afu_match].present?
                  options[:afu_match]
                else
                  $redis.afu_match!(match.key)
                end
    if parlay.nil?
      update_parlay
      reload
    end
    %i(play parlay).each do |type|
      afu_offer = afu_match[type][name.to_sym]
      db_offer  = type == :play ? self : parlay
      if afu_offer.available?
        if afu_offer[:asian_new] == false && db_offer.asian.present?
          afu_match.assign_offer(type, db_offer, afu_match.key)
        else
          afu_offer.sync(options)
        end
      else
        afu_match.assign_offer(type, db_offer, afu_match.key)
      end
    end
    afu_match.save!
  end
end
