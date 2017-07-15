module Cache
  module Match
    def afu_ref(key)
      hget($matches_ref, key)
    end

    def afu_match!(key)
      m = afu_match(key)
      return m if m
      raise Cache::MatchNotFound, "Match id or match_id: \"#{key}\" retrieves nil."
    end

    def afu_match(key, option = {})
      # return @afu_match if @afu_match
      m = hget($matches_key, key) || hget($matches_key, ::Match.find_by(id: key).try(:redis_id))
      if m
        m = m.from_marshal
        if option[:simple]
          m.delete(:parlay)
          m.delete(:play)
        end
      end
      # @afu_match = m
      m
    end

    def afu_matches?
      hlen($matches_key) > 0
    end

    def afu_matches
      hgetall($matches_key).each_with_object({}) do |match_pair, result|
        result[match_pair[0]] = match_open(match_pair[1])
      end
    end

    def afu_matches_by(category_ids, options = {})
      match_ids = ::Match.where(category_id: category_ids).active.pluck(:redis_id)
      result = {}
      return result if match_ids.blank?
      hmget($matches_key, match_ids).each_with_index do |raw, index|
        next if raw.nil?
        match = match_open(raw)
        next unless halves_match?(options[:type_id], match[:halves][:id])
        next unless is_running?(options[:is_running], match[:is_running])
        result[match_ids[index]] = match
      end
      result
    end

    def afu_matches_in(sport_name, options = {})
      category_ids = Sport.find_by_name(sport_name.to_s).categories.ids
      afu_matches_by(category_ids, options)
    end

    def random_afu_match
      afu_match(hkeys($matches_key).sample)
    end

    def match_open(match_string = "")
      match = match_string.from_marshal
      match.is_a?(::Match::Open) ? match : ::Match::Open.new(match)
    end

    def halves_match?(type_id, halves_id)
      return true if type_id.nil? || Info::OddCategory.allow_all?(type_id)
      # Info::OddCategory.match?(type_id, halves)
      type_id.to_i == halves_id
    end

    def is_running?(option_is_running, match_is_running)
      return true if option_is_running.nil?
      option_is_running.to_boolean == match_is_running
    end
  end
end
