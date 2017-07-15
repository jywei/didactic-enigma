puts 'Team seeds importing...'
# tx_teams = Marshal.load($redis.get('tx_teams'))



if Team.all.count > 0
  puts 'Team seeds has allredy run!'
else


    a = $redis.hgetall('tx_teams')
    puts " redis teams data => #{a.to_s[0..100]}"
    all_teams = a.each_with_object({}) do |team, tx_teams|
      tx_teams[team[0]] = JSON.parse(team[1]).with_indifferent_access
    end

    team_ids  = Team.all.pluck(:tx_id).compact.uniq

    all_teams.each do |key, values|
      sql       = "INSERT INTO `teams` (tx_id, name, created_at, updated_at) VALUES "
      time      = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
      insert_content = []
      values.each do |k, v|
        new_tx_id = k.to_i
        v = v.gsub("'", "''") if v.include?("'")
        insert_content << "(#{k}, '#{v}', '#{time}', '#{time}')" unless team_ids.include?(k.to_i)
        if insert_content.size > 1500
          ActiveRecord::Base.connection.execute("#{sql}#{insert_content.join(",")}")
          insert_content = []
        end
        team_ids.push(new_tx_id) unless team_ids.include?(new_tx_id)
      end
      ActiveRecord::Base.connection.execute("#{sql}#{insert_content.join(",")}") unless insert_content.empty?
    end


end