# 注單相對應的下注項目，儲存場次賠率等資訊
class Order::Item < ApplicationRecord
  belongs_to :order
  belongs_to :offer, polymorphic: true
  belongs_to :match
  belongs_to :sport, optional: true
  belongs_to :offer_type, class_name: "Offer::Type", primary_key: :id, foreign_key: :ot_id, optional: true
  has_one    :profile, class_name: 'Order::Item::Profile', dependent: :destroy, foreign_key: :order_item_id

  def brief
    # return nil unless order.item?
    {
      id:               id,
      category:         profile.category_name,
      h:                profile.hteam_name,
      a:                profile.ateam_name,
      target:           target,
      odd:              odd.to_f,
      head:             head,
      proportion:       proportion,
      offer_name:       Info::OddTypePush.name_to_ch(offer_name),
      halves:           Info::OddCategory.to_ch(profile.halves),
      match_start_time: profile.match_start_time.in_time_zone('Asia/Taipei').strftime("%m/%d %H:%M")
    }
  end
end
