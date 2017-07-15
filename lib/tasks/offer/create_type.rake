namespace :offer do
  task check_item: :environment do
    Order::Item.transaction do
      order_items = Order::Item.all
      order_items.each do |item|
        item.destroy! unless item.order
      end
    end
  end

  task add_type: :environment do
    Order::Item.transaction do
      order_items = Order::Item.all
      order_items.each do |item|
        offer_name = item.offer.name
        offer_type = item.order.type_flag
        item_ot_id =  if item[:offer_type] == "Offer::Parlay"
                        11
                      elsif offer_type == "running"
                        running_offer_type = {
                          "point"     => 5,
                          "ou"        => 6,
                          "ml"        => 17,
                          "odd_even"  => 14,
                          "one_win"   => 20,
                          "three_way" => 19
                        }
                        running_offer_type[offer_name]
                      else
                        normal_offer_type = {
                          "point"     => 1,
                          "ou"        => 2,
                          "ml"        => 3,
                          "odd_even"  => 4,
                          "one_win"   => 15,
                          "three_way" => 16
                        }
                        normal_offer_type[offer_name]
                      end
        item.update!(ot_id: item_ot_id)
      end
    end
  end
end
