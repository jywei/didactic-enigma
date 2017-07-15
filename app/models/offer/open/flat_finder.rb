# Offer::Open::FlatFinder 用於找最平盤球頭使用
class Offer::Open::FlatFinder
  # initialize時要帶入所有要找的玩法，參數的offers必須是 Offer
  def initialize(offers)
    @offers       = offers
    @active_ids   = []
    @inactive_ids = []
  end

  # 找到每一個玩法最平盤的球頭，回傳 Array
  def find_all
    @offers.map(&:name).uniq.map {|name| find(name) }
  end

  # 找到單一玩法最平盤球頭，通常用於new時所有 Offer 都屬於一種玩法
  def find_one
    find(@offers.first.name)
  end

  # 根據搜尋完球頭的結果，將所有 Offer 的 flat 欄位更新，最平球頭更新為 true，反之 false
  def update_all
    ::Offer.where(id: @active_ids.uniq).update_all(flat: true)    if @active_ids.any?
    ::Offer.where(id: @inactive_ids.uniq).update_all(flat: false) if @inactive_ids.any?
  end

  protected

    # 找到最平盤球頭
    def find(ot_name)
      offers = @offers.select { |o| o.name == ot_name }
      if Info::OddTypePush.multi_heads?(ot_name)
        offer = offers.sort { |a, b| a.odd_diff <=> b.odd_diff }.first
        # collect active & inactive ids
        offers.each {|o| @inactive_ids << o.id }
        @inactive_ids.delete offer.id
        @active_ids << offer.id
        offer
      else
        offers.first
      end
    end
end
