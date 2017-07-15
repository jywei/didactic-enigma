# 專門從 Offer 建立 Offer::Open 使用
module Offer::Open::Builder

  # 將 Offer 部份參數取出轉為一個 Offer::Open
  #
  # 參數match_key代表的是需要在 Offer::Open 底下儲存自己是屬於哪一個場次
  # 查詢場次時可避免多一次至db查詢
  def to_open(match_key)
    hash = basic_attributes
      .merge! default_odds
      .merge! default_position_attributes
      .merge! default_timestamp
    hash.merge! base_attrs       if is_a? Offer
    # 如果這筆 Offer 有是亞新盤就帶入亞新盤的賠率球頭等等
    hash.merge! asian_attributes if asian
    # 如果這筆 Offer 是three_way玩法的就寫入平手賠率參數
    hash.merge! draw_attributes  if three_way?
    # 如果這筆 Offer 不是串關，就加入賭金參數
    hash.merge! stakes           if not parlay?
    # 如果這筆 Offer 是串關，就加入串關id
    hash.merge! parlay_id        if parlay?
    ::Offer::Open.new(hash, match_key)
  end

  protected

    def basic_attributes
      {
        type:              name,
        type_ch:           Info::OddType.ch[name],
        head:              handicapped_team || 'h',  #head means handicap team
        # TODO: Will be removed ===
        asian:             name.in?(%w(ou point)),
        # ==========================
        has_head:          name.in?(%w(ou point)),
        asian_new:         false,
        is_parlay:         parlay?,
        handicapped:  {
          head:            head.to_f.abs,
          proportion:      0,
          modifier:        0
        },
        stat:              try(:stat) || 'unavailable',
        offer_id:          id,
        water:             water,
        running_water:     running_water,
        is_running:        false,
        index:             Info::OddType.indexes[name]
      }
    end

    def base_attrs
      {
        series: series
      }
    end

    def stakes
      attrs(*%i(h_stake a_stake d_stake))
    end

    def parlay_id
      {
        parlay_id:    id
      }
    end

    def default_odds
      {
        h:            h_odd.to_f.round(3),
        a:            a_odd.to_f.round(3),
        h_modifier:   h_modifier.to_f.round(3),
        a_modifier:   h_modifier.to_f.round(3)
      }
    end

    def default_position_attributes
      {
        positions:    team_attributes,
        thresholds:   team_attributes(-2_000_000),
        distances:    team_attributes,
        wager:        team_attributes
      }
    end

    def asian_attributes
      asian_offer = self.asian
      {
        asian_new:    true,
        head:         asian_offer.handicapped_team,
        handicapped: {
          head:       asian_offer.asian_head.to_i,
          proportion: asian_offer.asian_proportion.to_i,
          modifier:   asian_offer.asian_modifier.to_i
        },
        h:            asian_offer.h_odd.to_f.round(3),
        a:            asian_offer.a_odd.to_f.round(3),
        h_modifier:   asian_offer.h_modifier.to_f.round(3),
        a_modifier:   asian_offer.a_modifier.to_f.round(3),
        offer_id:     asian_offer.offer_id,
        asian_id:     asian_offer.id,
        water:        asian_offer.water.to_f.round(4)
      }
    end

    def default_timestamp
      {
        last_updated: {
          h:          DateTime.mil,
          a:          DateTime.mil,
          asian:      DateTime.mil,
          push:       DateTime.now.strftime('%Y-%m-%d %H:%M:%S')
        }
      }
    end

    def team_attributes(default_value = 0)
      {
        h: default_value,
        a: default_value
      }.merge(three_way? ? { d: default_value } : {})
    end

    def draw_attributes
      {
        d:          d_odd.to_f.round(3),
        d_modifier: d_modifier.to_f.round(3)
      }
    end
end
