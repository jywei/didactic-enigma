require 'mysql2'

module Odd
  class Connection
    attr_reader :connection

    def initialize
      @connection = Mysql2::Client.new(config)
    end

    def config
      config = ActiveRecord::Base.connection.instance_variable_get(:@config)
      {
        host: config[:host],
        username: config[:username],
        password: config[:password],
        database: config[:odds_service]['database']
      }
    end
  end
end
