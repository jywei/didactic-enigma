# Sport 儲存所有運動項目
class Sport < ApplicationRecord

# => Relation
  has_many :categories, primary_key: :leader_spid, foreign_key: :spid
  accepts_nested_attributes_for :categories
# => Validates
  validates_uniqueness_of :leader_spid
  validates_presence_of :name
# =>  Scope
  scope :active, -> { where(active: true) }
  scope :few_category, -> { joins( :categories ).joins( :matches ).group( 'category_id' ).having( "count( leader_id ) > 10 AND active = true" ) }



  def self.to_dict
    active.reduce({}) {|result, sport|
      result[sport.id.to_s] = sport.display_name
      result
    }
  end

end
