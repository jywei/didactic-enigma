# 專門儲存跟這筆訂單相關的場次內容，主要是場次內容會移至歷史場次，為避免資料遺失以及存取較快速，
# 於產生注單時會儲存一份場次及玩法的相關內容至此。
class Order::Item::Profile < ApplicationRecord
  belongs_to :order_item, class_name: 'Order::Item', foreign_key: :order_item_id
  validates :order_item_id, uniqueness: true
end
