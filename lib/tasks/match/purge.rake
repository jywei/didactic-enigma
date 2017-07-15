namespace :match do
  task purge: :environment do
    $redis.db.del($matches_key)
    $redis.db.del($categories_key)
    $redis.db.del($matches_ref)
    Match.delete_all
    Offer.delete_all
    Order.delete_all
    Order::Item.delete_all
    Log::Push.delete_all
    $redis.db.del($user_key)
  end
end
