namespace :redis do
  task import: :environment do
    # production key
    prod_setting = {
      afu_matches: $matches_key,
      afu_matches_ref: $matches_ref,
      afu_categories: $categories_key
    }
    if Rails.env.production?
      puts "Redis production-to-development backup cannot be executed in production environment"
      return
    end

    if not prod_setting.keys.all? {|k| $redis.exists(k)}
      puts "Production keys not found. Probably you're not using production Redis."
      return
    end

    prod_setting.each do |key, val|
      puts "Importing #{key}"
      vals = $redis.hgetall(key).map{|k, v| [k, v]}.flatten
      puts "#{vals.size / 2} keys found"
      if vals.present?
        $redis.del(val)
        $redis.hmset(val, *vals)
      end
    end

  end
end
