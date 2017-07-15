# require 'mysql2'
#
# config = ActiveRecord::Base.connection.instance_variable_get(:@config)
# {
#   host: config[:host],
#   username: config[:username],
#   password: config[:password],
#   database: config[:database]
# }
#
# $mysql = Mysql2::Client.new(config)
#
# class << $mysql
#   def insert(table_name, columns_string, values_string)
#     # time = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
#     # values_string.gsub!("'", "\'")
#     # query("INSERT INTO `#{table_name}` (#{columns_string} created_at, updated_at) VALUES (#{values_string} '#{time}', '#{time}')")
#   end
# end
