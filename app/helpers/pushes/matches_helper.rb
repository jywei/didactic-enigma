module Pushes::MatchesHelper
  def highlight_if_flat(offer, flat_offer)
    'blanchedalmond' if offer.id == flat_offer.id
  end
end
