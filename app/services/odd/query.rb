module Odd
  class Query
    def initialize
      @db ||= Odd::Connection.new.connection
    end

    def last_tx_log
      @db.query("SELECT last_updated FROM `offers` ORDER BY last_updated DESC LIMIT 1").entries.first
    rescue => e
      if e.message.include?("Unknown database")
        return nil
      else
        raise e
      end
    end

    def close
      @db.close
    end

    class << self
      def db
        @db ||= Odd::Connection.new.connection
      end

      def find_team_name(tx_team_id)
        db.query("SELECT `name_cn` FROM `teams` WHERE `leader_tid` = '#{tx_team_id}'").entries.first.try(:[], 'name_cn')
      end

      def update_team_cn
        entries = db.query("SELECT `name_cn`, `leader_tid` FROM `teams` WHERE `name_cn` IS NOT NULL").entries
        teams   = Team.where(name_cn: nil, tx_id: entries.map{|n| n['leader_tid']})
        entries = entries.reduce({}) do |result, entry|
          result[entry['leader_tid'].to_s] = entry['name_cn']
          result
        end
        teams.each do |team|
          team.update(name_cn: entries[team.tx_id.to_s])
          puts entries[team.tx_id.to_s]
          raise("Not Found: #{team.tx_id}") if entries[team.tx_id.to_s].nil?
        end
      end

      def update_all_teams
        puts "querying teams from odds_service"
        @auli_teams = (Odd::Connection.new.connection.query("SELECT `leader_tid`, `name`, `name_cn` FROM `teams`").entries.map {|team| [team["leader_tid"], [team["name"], team["name_cn"]]] }).to_h
        puts "querying teams from db"
        teams = Team.all
        teams.each do |team|
          if a = @auli_teams[team.tx_id.to_i]
            if a[0] == team.name && a[1] == team.name_cn
              puts "Skipped: id #{team.id}, to: name: #{team.name}, name_cn: #{team.name_cn}"
              puts "Data from odds_service: name: #{a[0]}, name_cn: #{a[1]}"
            else
              team.update!(name: a[0], name_cn: a[1])
              puts "Updated: id #{team.id}, to: name: #{a[0]}, name_cn: #{a[1]}"
            end
          end
        end
      end

    end
  end
end
