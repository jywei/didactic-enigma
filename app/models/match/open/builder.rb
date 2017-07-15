# 專門從 Match 建立 Match::Open 使用
module Match::Open::Builder
  def self.included(klass)
    def klass.to_open
      all.map(&:to_open)
    end

    def klass.open!
      matches    = active.with_data
      size       = matches.size
      match_keys = $redis.afu_matches.keys
      puts "#{size} active matches found" unless Rails.env.test?
      matches.each_with_index do |m, i|
        next if match_keys.include?(m.id.to_s)
        begin
          m.open!
        rescue => e
          puts "#{e.class} #{e.message}"
          puts "#{e.backtrace}"
        end
        print "Processed: #{i + 1}\r" unless Rails.env.test?
      end
    end
  end

  # 將 Match 部份參數取出，並連同底下的 Offer 一起轉為一場 Match::Open
  def to_open
    offer_hash = { id: id, key: key, three_way: three_way? }
    ofs = offers
    if ofs.any? && available == false
      update_column(:available, true)
    end
    hash = {
      id:               id,
      # === 修改好後會移除
      match_id:         key,
      halves_match_id:  match_id,
      # ===
      # === 新的
      _match_id:        match_id,
      _halves_match_id: key,
      # ===
      match_number:     match_number,
      start_time:       start_time.in_time_zone('Asia/Taipei').strftime('%Y/%m/%d %H:%M'),
      start_time_int:   start_time.in_time_zone('Asia/Taipei').to_i,
      halves:       {
        id:             Info::OddCategory.en_to_id(halves),
        slug:           halves,
        name:           Info::OddCategory.to_ch(halves)
      #   index:      0
      },
      sport:            category.slug,
      team:         {
        home:           [hteam.id, hteam.display_name],
        away:           [ateam.id, ateam.display_name]
      },
      play:             Offer::Open::Collection.new(ofs, offer_hash).fill,
      parlay:           Offer::Open::Collection.new(parlays, offer_hash).fill,
      h_stake:          h_stake,
      a_stake:          a_stake,
      h_score:          h_score,
      a_score:          a_score,
      match_result:     result,
      is_running:       false,
      stat:             'normal',
      book_maker:       book_maker.name,
      group_id:         group.try(:id)
    }
    meta = {
      order_id:    "#{leader_id}#{book_maker_id}",
      category_id: category.id,
      sport_id:    category.sport.id,
      halves_id:   Info::OddCategory.en_to_id(halves),
      available:   available
    }
    hash[:d_stake] = d_stake if category.d_stake?
    afu_match = ::Match::Open.new(self, data: hash, meta: meta)
    afu_match
  end

  # 執行完 #to_open 之後直接儲存至redis
  def open!
    @open = to_open
    if @open
      @open.save!
      save_ref
      save_timestamp
      create_positions unless offer_positions.any?
    end
    @open
  end

  def create_positions
    sql    = "INSERT INTO `offer_positions` (offer_name, match_id, created_at, updated_at) VALUES "
    values = []
    time   = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
    @open[:play].each { |offer_name, _| values << "('#{offer_name}', #{id}, '#{time}', '#{time}')" }
    Offer::Position.connection.execute("#{sql}#{values.join(",")}")
  end

  def save_ref
    $redis.db.hset($matches_ref, key, id)
  end

  def save_timestamp
    $redis.db.hset(
      $user_key,
      id.to_s,
      @open.default_offer_timestamp
    )
  end

  def match_number
    "#{category.slug}#{start_time.wday}#{id}"
  end
end
