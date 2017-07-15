class Log::Position::Warning < ApplicationRecord
  belongs_to :match, optional: true

  def create_time_filter(create_time)
    return true unless create_time
    created_at.to_date.in? create_time
  end

  def match_time_filter(match_time)
    return true unless match_time
    match_time.to_date.in? match_time
  end

  def match_filter(match_ids)
    return true unless match_ids
    match_id.to_s.in? match_ids
  end

  def sport_filter(sport_ids)
    return true unless sport_ids
    sport_id.to_s.in? sport_ids
  end

  def category_filter(category_ids)
    return true unless category_ids
    category_id.to_s.in? category_ids
  end

  def position_log_warning_filter(match_ids, sport_ids, category_ids, create_time, match_time)
    create_time_filter(create_time) && match_time_filter(match_time) && match_filter(match_ids) && sport_filter(sport_ids) && category_filter(category_ids)
  end

  def self.position_log_warning_filter(match_ids, sport_ids, category_ids, create_time, match_time)
    select { |log| log.position_log_warning_filter(match_ids, sport_ids, category_ids, create_time, match_time) }.to_a
  end
end
