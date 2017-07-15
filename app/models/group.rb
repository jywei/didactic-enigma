# Group 儲存聯盟項目，隸屬於Category底下
class Group < ApplicationRecord
  belongs_to :category
  scope :search, -> (search) { includes(:category).where("display_name LIKE ?", "%#{search}%") }

  # 根據 `search` 參數搜尋並顯示相關的 Group
  def self.search_data(search)
    if search.present?
      search(search).map(&:data)
    else
      limit_data
    end
  end

  # 取得前100筆 Group
  def self.limit_data
    Group.all.limit(100).map(&:data)
  end

  def data
    {
      id: id,
      name: tx_name,
      display_name: display_name
    }
  end
end
