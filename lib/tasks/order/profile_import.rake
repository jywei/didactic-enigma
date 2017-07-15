namespace :order do
  task import_profile: :environment do
    all_ids = []
    Order::Item.includes(:profile).all.each {|i| all_ids << i.id if i.profile.nil? }
    order_items = Order::Item.where(id: all_ids)
    # order_items = Order::Item.all
    idd = order_items.last.id
    query = "INSERT INTO order_item_profiles(`order_item_id`, `hteam_name`, `ateam_name`, `category_name`, `match_start_time`, `halves`, `created_at`, `updated_at`) VALUES "
    order_items.includes(:order, match: [:category, :hteam, :ateam]).each do |record|
      if record.order
        target_match = record.match
        value = "(#{record.id}, \'#{target_match.hteam.display_name}\', \'#{target_match.ateam.display_name}\', \'#{target_match.category.name}\', \'#{target_match.start_time.strftime("%FT%T")}\', \'#{target_match.halves}\', \'#{Time.now.strftime("%FT%T")}\', \'#{Time.now.strftime("%FT%T")}\')"
        value += ", " if record.id != idd
        query += value
      end
    end
    ActiveRecord::Base.connection.execute(query)
  end
end
