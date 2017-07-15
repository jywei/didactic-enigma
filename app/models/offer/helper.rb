# 所有 Offer 共用的 methods
module Offer::Helper
  def odd_diff
    (h_odd.to_f - a_odd.to_f).abs
  end

  def three_way?
    name == 'three_way'
  end

  def parlay?
    is_a? Offer::Parlay
  end

  def asian?
    is_a? Offer::Asian || (is_a?(Offer::Parlay) && try(:type_flag) == "asian")
  end
end
