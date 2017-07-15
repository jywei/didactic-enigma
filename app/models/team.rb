# Team 儲存所有TX提供的隊伍
class Team < ApplicationRecord
  belongs_to :category, optional: true
  scope :team, -> (category_id) {includes(:category).where(category_id: category_id) }
  scope :search, -> (search) {includes(:category).where("name_cn LIKE ?", "%#{search}%")}
  validates_uniqueness_of :tx_id

  class << self
    def team_data(category_id)
      team(category_id).map(&:data)
    end

    def search_data(search)
      search(search).map(&:data)
    end

    def limit_data
      limit(100).map(&:data)
    end
  end

  def display_name
    name_cn || name
  end

  def update_name_cn
    cn = Odd::Query.find_team_name(tx_id)
    if cn
      update!(name_cn: cn)
      cn
    else
      nil
    end
  end

  def refresh_name_cn
    update_column(:name_cn, nil)
    update_name_cn
  end

  def fix_name
    Odd::Query.find_team_name(tx_id)
  end

  def data
    {
      id: id,
      name: name,
      display_name: name_cn
    }
  end

end
