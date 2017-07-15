namespace :order do
  task icehockey_setting: :environment do 
    Order::Item.where(sport_name: "ice hockey").update_all(sport_name: "icehockey")
    User::Allotter.where(name: "ice hockey").update_all(name: "icehockey")
    User::Setting.where(name: "ice hockey").update_all(name: "icehockey")
  end
end
