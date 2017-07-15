namespace :order do
  task clear: :environment do 
  	Order.destroy_all
  	# => 有關Order的都要設depend，自動刪除，沒有設的要補
  end
end