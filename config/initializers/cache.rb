$redis = Cache::Server.new

$machine_prefix   = Socket.gethostname.gsub(/[^0-9A-Za-z]/, '')[0..6]
$redis_key_prefix = if Rails.env.development?
                      "#{$machine_prefix}_afu_dev"
                    elsif Rails.env.test?
                      'afu_test'
                    elsif Rails.env.production?
                      'afu'
                    end
$matches_key    = "#{$redis_key_prefix}_matches"
$matches_ref    = "#{$redis_key_prefix}_matches_ref"
$categories_key = "#{$redis_key_prefix}_categories"
$matches_lock   = "#{$redis_key_prefix}_matches_lock"
$user_key       = "#{$redis_key_prefix}/matches_user"

#`RAILS_ENV=production rake order:settled`
