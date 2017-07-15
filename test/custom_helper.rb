module CustomHelper
  def set_asia_default_prob
    file = File.open("#{Rails.root}/lib/csv/asia_prob.csv")
    AsiaOffer.default_prob($redis, "asia_prob", file)
  end
end
