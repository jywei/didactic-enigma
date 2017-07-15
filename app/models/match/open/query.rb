# 專門提供API拉取redis內儲存的 Match::Open 使用
module Match::Open::Query
  # 藉由不同參數來過濾比賽場次
  #
  # ```ruby
  # {
  #   sport_id: Integer,
  #   league_id: Integer,
  #   type_id: Integer,
  #   custom_id: Integer,
  #   action: String
  # }
  # ```
  def query_by(args)
    @matches   = {}
    @groups    = []
    case
    when args[:sport_id]
      sport    = Sport.find_by(leader_spid: args[:sport_id])
      ids      = sport.categories.ids
      matches  = $redis.afu_matches_by(ids, type_id: args[:type_id], is_running: args[:is_running])
      offers   = Info::OddType.by_sport(sport.name)
    when args[:league_id]
      matches  = $redis.afu_matches_by([args[:league_id]], type_id: args[:type_id], is_running: args[:is_running])
      category = Category.find_by(id: args[:league_id]) || raise("Category with id from args[:league_id] #{args[:league_id]} not found")
      offers   = Info::OddType.by_sport(category.sport.name)
    when args[:custom_id]
      # TODO: 尚未接
    else
      Rails.logger.info("No param specified. Querying matches with default category.")
      category = Category.find_by(name: 'NBA') || raise("Category with id from default category #{id} not found")
      matches  = $redis.afu_matches_by([category.id])
      offers   = Info::OddType.by_sport(category.sport.name)
    end
    matches = matches.sort.to_h
    index_and_filter!(matches, args[:parlay], args[:action])
    matches.values.each do |match|
      all_offers = match["play"].values
      if args[:action] == :group
        reduce_odd_and_modifier(all_offers, args[:action])
      elsif args[:action] == :group_player
        reduce_odd_and_modifier(all_offers)
      end
    end
    if args[:action] == :group || args[:action] == :group_player
      {
        matches: @matches,
        groups: @groups,
        offers: offers
      }
    else
      {
        matches: matches,
        offers:  offers
      }
    end
  end

  # 將過濾出來的場次加上index，並移除不需要的資訊內容
  def index_and_filter!(matches, parlay, action = :list)
    return if matches.blank?
    remove_attr = parlay == 'true' ? :play : :parlay
    matches.each do |key, match|
      # filter
      unless match.available?
        matches.delete(key)
        next
      end

      match.remove_offer_type(remove_attr)

      # group
      next unless (action == :group || action == :group_player)
      match_id        = match[:_match_id]
      halves_match_id = match[:_halves_match_id]
      @groups << match[:group_id] unless @groups.include?(match[:group_id]) || match[:group_id].nil?
      if @matches.keys.include? match_id
        @matches[match_id].matches[halves_match_id] = match.to_group_match
        %i(h_stake a_stake d_stake).each do |stake|
          @matches[match_id][stake] += match[stake] if @matches[match_id][stake]
        end
      else
        @matches[match_id] = match.to_group
        @matches[match_id].matches[halves_match_id] = match.to_group_match
      end
    end

    return unless (action == :group || action == :group_player)
    @groups = @groups.reduce({}) { |result, id| result[id.to_s] = ::Group.find(id).display_name ; result }
    @matches.each do |_key, match|
      match[:disabled] = match.matches.all? {|_key, halves| halves[:stat] == 'disabled' }
    end
  end

  def reduce_odd_and_modifier(offers, action = :group_player)
    offers.each do |o|
      arr = o["d"] ? %w(h a).push("d") : %w(h a)
      handicapped = o["handicapped"]
      if action == :group
        arr.each do |i|
          o["#{i}_base"] = o["#{i}"].to_f
          o["#{i}"] = o["#{i}_base"].to_f + o["#{i}_modifier"].to_f
        end
        handicapped["base_proportion"] = handicapped["proportion"].to_f
        handicapped["proportion"] = handicapped["proportion"].to_f + handicapped["modifier"].to_f
      else
        arr.each do |i|
          o["#{i}"] = o["#{i}"].to_f + o["#{i}_modifier"].to_f
          o.delete("#{i}_modifier")
        end
        handicapped["proportion"] = handicapped["proportion"].to_f + handicapped["modifier"].to_f
        handicapped.delete("modifier")
      end
    end
  end

  def query_positions(args)
    result = query_by(args)
    result[:matches] = result[:matches].each_with_object({}) do |match, matches|
      matches[match[0]] = match[1].to_position
    end
    result
  end

  def count_by_categories
    Match.includes(category: :sport).active.reduce({}) {|result, match|
      sport              = "sport:#{match.category.sport.id}"
      league             = "league:#{match.category_id}"
      halves             = "#{league}:#{Info::OddCategory.en_to_id(match.halves)}"
      halves_all         = "#{league}:#{Info::OddCategory.en_to_id('all')}"
      result[sport]      = result[sport]      ? result[sport]      + 1 : 1
      result[league]     = result[league]     ? result[league]     + 1 : 1
      result[halves]     = result[halves]     ? result[halves]     + 1 : 1
      result[halves_all] = result[halves_all] ? result[halves_all] + 1 : 1
      result
    }
  end
end
