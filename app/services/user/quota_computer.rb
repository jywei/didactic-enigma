module User::QuotaComputer
  def calculate_current_quota(user)
    @profile = User::Profile.find_by(user_id: user.id)
    used_quota = user.orders.where(created_at: check_date).sum(:amount).to_i
    current_quota = (@profile.quota * 10_000 - used_quota) / 10_000
    @profile.update_attributes(current_quota: current_quota)
  end

  def check_date
    now         = Time.now
    midday      = now.midday
    start_time  = now > midday ? midday : midday - 1.day
    start_time..(start_time + 1.day)
  end
end
