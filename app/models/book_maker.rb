# BookMaker 儲存所有的賠率提供商，資料從TX的Pull來
class BookMaker < ApplicationRecord
# => Relation
# => Validates
  validates_uniqueness_of :tx_id
  validates_presence_of :name
# =>  Scope

end
