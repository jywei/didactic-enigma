class VigorishShare < ApplicationRecord
  belongs_to :order, class_name: "Order", primary_key: :id, foreign_key: :order_id
  scope :search_orders, -> (order_ids) { where( "order_id in (?)", order_ids ) }
end
