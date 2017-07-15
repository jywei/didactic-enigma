# 每一個 Offer::Open::Collection 底下都會有五個 Offer::Open，
# 代表在同一場次 Match::Open 底下的所有 Offer::Open。
#
# 一般來說，一個 Match::Open 底下會各有一組一般玩法和串關玩法的 Offer::Open::Collection，
#
# ```ruby
# match = Match.last.to_open
# match[:play].class # => Offer::Open::Collection
# ```
class Offer::Open::Collection < ActiveSupport::HashWithIndifferentAccess
  def initialize(offers, args = { id: nil, key: nil, three_way: false })
    @offers       = offers.to_a
    @paused       = args[:paused]
    @disabled     = args[:disabled]
    @three_way    = args[:three_way]
    @match_key    = args[:key]
    @active_ids   = []
    @inactive_ids = []
  end

  def match
    $redis.afu_match!(@match_key)
  end

  # 將這場 Match::Open 底下的所有 Offer::Open 依照玩法補滿
  # 若未開就是組成一個 unavailable 的 Offer::Open
  def fill
    fill_available_offers
    fill_unavailable_offers
    self
  end

  def stat(offer_name)
    if paused?(offer_name)
      'paused'
    elsif disabled?(offer_name)
      'disabled'
    else
      'normal'
    end
  end

  def paused?(offer_name)
    @paused.include?(offer_name)
  end

  def disabled?(offer_name)
    @disabled.include?(offer_name)
  end

  def disable_unlive_offers(offer)
    each do |k, v|
      next if v[:type] == offer[:type]
      v["stat"] = "disabled" if !v.live? && v.available?
    end
  end

  protected

  def fill_available_offers
    finder = ::Offer::Open::FlatFinder.new(@offers)
    finder.find_all.each {|offer| self[offer.name] = offer.to_open(@match_key) }
    finder.update_all
  end

  def fill_unavailable_offers
    Info::OddType.full.each do |odd_type|
      next if keys.include?(odd_type[:ot_name])
      next if odd_type[:ot_name] == 'three_way' && @three_way.!
      next if odd_type[:ot_name] == 'ml' && @three_way
      self[odd_type[:ot_name]] = Offer.new(
        name:       odd_type[:ot_name],
        updated_at: Time.now
      ).to_open(@match_key)
    end
  end

end
