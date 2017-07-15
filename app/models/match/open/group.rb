# 包在 Match 上面的 Group，例如NBA底下的季後賽
class Match::Open::Group < ActiveSupport::HashWithIndifferentAccess
  def matches
    self[:halves_matches]
  end
end
