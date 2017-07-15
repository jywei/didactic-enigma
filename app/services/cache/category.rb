module Cache
  # 在redis當中存取相關的category，主要提供API拉取目前「已選取」及「未選取」項目
  class Category
    class << self

      # 從資料庫取得所有目前正在使用的sport及category
      def all
        Sport.active.includes(:categories).map do |sport|
          {
            type: 'sport',
            id:   sport.leader_spid,
            name: sport.display_name || sport.name,
            sub:  sport.categories.empty? ? Info::OddCategory.array : convert_to_league(sport.categories)
          }
        end
      end

      def reset
        data = Marshal.dump(
          {
            unselected: Cache::Category.all,
            selected: []
          }
        )
        $redis.set("#{$redis_key_prefix}/play:categories", data)
        selected
      end

      # 取得目前儲存在redis內所有項目，包含「未選取」和「已選取」項目
      def selection
        raw = $redis.get("#{$redis_key_prefix}/play:categories")
        raw ? Marshal.load(raw) : default_selection
      end

      # 取得目前儲存在redis內「已選取」項目
      def selected
        s = selection['selected'] || selection[:selected]
        if s.blank?
          default              = default_selection
          default[:selected]   = default[:unselected]
          default[:unselected] = []
          $redis.set("#{$redis_key_prefix}/play:categories", Marshal.dump(default))
          s = selection[:selected]
        end
        s
      end

      # 從目前儲存在redis內「已選取」項目當中過濾，只留下目前尚未開打比賽場次的項目
      def with_matches
        categories = selected
        return if categories.blank?
        @counts    = ::Match::Open.count_by_categories
        rebuild_sport_category(categories)
      end

      def update_cache(type, id, name)
        raw = selection.with_indifferent_access
        raw.each do |key, value|
          update_name(value, type, id, name)
        end
        $redis.set("#{$redis_key_prefix}/play:categories", Marshal.dump(raw))
      end

      protected

        def update_name(select, type, id, name)
          select.each do |sub_select|
            prefix =
              case sub_select[:type]
              when 'sport'
                type == 'sport' ? "" : nil
              when 'league'
                type == 'sport' ? "sport_" : ""
              when 'halves'
                type == 'sport' ? "sport_" : "league_"
              end
            sub_select["#{prefix}name"] = name if sub_select["#{prefix}id"] == id && prefix
            update_name(sub_select[:sub], type, id, name) if sub_select[:sub].present?
          end
        end

        def rebuild_sport_category(categories)
          categories.map do |category|
            category = category.with_indifferent_access
            count = @counts["#{category['type']}:#{category['id']}"].to_i
            count < 1 ? next : category['count'] = count

            return category.to_hash if category['sub'].nil?
            
            category['sub'] = rebuild_sub_category(category)
            category.to_hash
          end.compact
        end

        def rebuild_sub_category(category)
          category['sub'].map do |sub_category|
            case sub_category['type']
            when 'league'
              count = @counts["#{sub_category['type']}:#{sub_category['id']}"].to_i
              count < 1 ? next : sub_category['count'] = count

              return sub_category.to_hash if sub_category['sub'].nil?

              sub_category['sub'] = sub_category['sub'].map do |halves|
                rebuild_halves_category(sub_category, halves)
              end.compact
              sub_category.to_hash
            when 'halves'
              rebuild_halves_category(category, sub_category)
            end
          end.compact
        end

        def rebuild_halves_category(sub_category, halves)
          count = @counts["#{sub_category['type']}:#{sub_category['id']}:#{halves['id']}"].to_i
          return if count < 1
          halves['count'] = count
          halves.to_hash
        end

        def convert_to_league(categories)
          return [] if categories.empty?
          categories.map do |category|
            next if category.name.nil? || category.name.to_s.empty?
            sport = category.sport
            {
              type:       'league',
              id:         category.id,
              name:       category.display_name || category.name,
              sport_id:   sport.leader_spid,
              sport_name: sport.display_name || sport.name,
              sub:        category.ot
            }
          end.compact
        end

        def default_selection
          {
            unselected: all,
            selected: []
          }
        end

    end
  end
end
