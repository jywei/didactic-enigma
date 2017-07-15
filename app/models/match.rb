# 在控台中儲存的比賽項目
class Match < ApplicationRecord
  include Open::Builder
  include Close
  include Operation::Odd::Algorithm

  belongs_to :category
  belongs_to :hteam, class_name: 'Team', foreign_key: :hteam_id
  belongs_to :ateam, class_name: 'Team', foreign_key: :ateam_id
  belongs_to :book_maker
  belongs_to :group, optional: true
  has_many :offers, dependent: :destroy
  has_many :parlays,  class_name: 'Offer::Parlay', dependent: :destroy
  has_many :push_logs, class_name: 'Log::Push', foreign_key: :tx_match_id, primary_key: :leader_id, dependent: :destroy
  has_many :offer_positions, class_name: 'Offer::Position', dependent: :destroy
  has_many :log_position_warnings, class_name: 'Log::Position::Warning', dependent: :destroy
  has_many :results, class_name: 'Match::Result', dependent: :destroy

  scope :with_data, -> { includes(:book_maker, :hteam, :ateam, :parlays, :offer_positions, category: :sport, offers: [:match, :book_maker, :asian]) }
  scope :active,    -> { where(active: true) }
  scope :authentic, -> { where.not(category: Category.find_or_create_by(sport: Sport.find_or_create_by(name: 'test'))) }
  scope :faker,     -> { where(category: Category.find_or_create_by(sport: Sport.find_or_create_by(name: 'test'))) }
  scope :outdated,  -> { where('start_time < ?', Time.now - 3.hours) }

  validates_uniqueness_of :halves, scope: %i(leader leader_id book_maker_id)
  validates :halves, presence: true

  before_create :set_redis_id

  def h_stake
    offers.map(&:h_stake).sum
  end

  def a_stake
    offers.map(&:a_stake).sum
  end

  def d_stake
    offers.map(&:d_stake).sum
  end

  def self.update_positions
    all.each(&:update_positions)
  end

  def afu
    $redis.afu_match(key)
  end

  def close_with(h_score, a_score)
    update!(h_score: h_score, a_score: a_score, active: false)
    $redis.db.rpush("#{$redis_key_prefix}/order_jobs", redis_id) && $redis.hdel($matches_key, redis_id)
  end

  def update_positions
    offer_positions.update_with(afu.offers) if afu
  end

  def self.regenerate_faker
    faker.each do |match|
      $redis.db.hdel($matches_key, match.id.to_s)
      $redis.db.hdel($matches_ref, match.leader_id.to_s)
    end
    transaction { require "#{Rails.root}/db/seeds/faker" }
  end

  def collect_leader_offers(exclude = nil, push_log = nil)
    push_log.push("Processing, skipping offer with leader_id #{exclude}")
    # return unless leader_match = $redis.send("#{leader}_match", leader_id)
    return unless leader_match = $redis.tx_match(leader_id)
    push_log.push("Leader match found: #{leader_match}")
    spid = category.spid
    leader_match[:offer_id].try(:each) do |offer_id|
      push_log.push("Processing #{offer_id}")
      # leader_offer = $redis.send("#{leader}_offer", offer_id)
      leader_offer = $redis.tx_offer(offer_id)
      unless leader_offer
        push_log.push("Skipped: not found.")
        next
      end
      if halves != Info::OddTypePush.type(leader_offer[:ot_id])
        push_log.push("Skipped: match halves '#{halves}' does not match '#{leader_offer[:ot_id]}. #{Info::OddTypePush.type(leader_offer[:ot_id]) || 'Not Found'}'")
        push_log.push("tx_offer data: #{leader_offer}")
        next
      end
      if exclude && exclude == offer_id
        push_log.push("Skipped: ID #{exclude} is excluded according to the argument")
        next
      end
      current_book_maker = BookMaker.find_by_tx_id(leader_offer[:bid])
      if current_book_maker.id != book_maker.id
        push_log.push("Skipped: incoming book_maker #{current_book_maker.id}. #{current_book_maker.name} does not match book_maker #{book_maker.id}. #{book_maker.name}")
        next
      end
      hash = leader_offer.keep(:h_oppo, :a_oppo, :d_oppo, :head).merge!(
        name:        Info::OddTypePush.name(
          leader_offer[:ot_id],
          leader_offer[:head],
          spid
        ),
        h_odd:       oppo_to_odd(leader_offer[:h_oppo]),
        a_odd:       oppo_to_odd(leader_offer[:a_oppo]),
        d_odd:       oppo_to_odd(leader_offer[:d_oppo]),
        leader:      'tx',
        leader_id:   offer_id,
        book_maker:  current_book_maker,
        flag:        1,
        stat:        'normal',
        flat:        true,
        category_id: category.id
      )
      push_log.push("Creating offer with data: #{hash}")
      offer = offers.new(hash)
      if offer.save
        h = { head: offer.head, name: offer.name, match_id: offer.match_id, leader_id: offer.leader_id, book_maker: offer.book_maker_id }
        push_log.push("offer created with ID ##{offer.id}: #{h}")
      else
        push_log.push("Can't create offer. Validation message: #{offer.errors.messages}")
      end
    end
  end

  def three_way?
    category.has_three_way?
  end

  def match_id
    "#{leader_id}#{book_maker_id}"
  end

  # The key that stored in redis
  #
  # Example:
  #
  #     key = Match.last.key
  #
  def key
    "#{start_time.in_time_zone('Asia/Taipei').strftime('%m%d%H%M')}_#{leader_id}_#{book_maker_id}_#{Info::OddTypePush.type_to_i(halves)}"
  end

  def set_redis_id
    self.redis_id = key
  end
end
