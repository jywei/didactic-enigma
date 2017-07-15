module MatchesHelper
  def odd_to_oppo(h_odd, a_odd, d_odd)
    h_reverse = h_odd == 0.0 ? 0.0 : 1.0 / h_odd
    a_reverse = a_odd == 0.0 ? 0.0 : 1.0 / a_odd
    d_reverse = d_odd == 0.0 ? 0.0 : 1.0 / d_odd
    total     = h_reverse + a_reverse + d_reverse
    [
      (h_reverse / total).round(4),
      (a_reverse / total).round(4),
      (d_reverse / total).round(4)
    ]
  end
  
  def oppo_round(odd_num, r_num)
    odd_num.round(r_num) unless odd_num.nil?
  end

end
