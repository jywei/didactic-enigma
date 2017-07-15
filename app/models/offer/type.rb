# 所有的玩法類別，僅在 User::Setting當中使用，目前開盤等機制仍使用 Info::OddTypePush
class Offer::Type < ApplicationRecord
# => Relation
  has_many :order_items, class_name: 'Order::Item', primary_key: :id, foreign_key: :ot_id

# => Validates
  validates_uniqueness_of :name

# =>  Scope
  scope :parlay,  -> { where(parlay: true,  running: false) }
  scope :running, -> { where(parlay: false, running: true)  }
  scope :normal,  -> { where(parlay: false, running: false) }



end
