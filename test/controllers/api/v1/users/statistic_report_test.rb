require 'test_helper'

class Api::V1::UsersControllerStatisticReportTest < ActionDispatch::IntegrationTest
  def setup
    db = ActiveRecord::Base.connection
    db.execute(File.read("db/fakers/users.sql"))
    db.execute(File.read("db/fakers/user_settings.sql"))
    db.execute(File.read("db/fakers/user_allotters.sql"))
    @agent       = User.find(50)
    @member      = User.find(51)
    @order       = create(:order, amount: 500, user: @member, created_at: Time.now.monday)
    create(:user_ancestor, member: @member.id, user_id: @member.id, agent: @agent.id)
    now_time     = Time.now
    midday       = now_time.midday
    start_of_day = midday + 12.hour
    start_time   = now_time >= midday ? start_of_day : start_of_day - 1.day
    @order.item.profile.update_attributes(match_start_time: start_time)
    (75..76).each { |id| Sport.create(id: id, active: true) }
  end

  def test_statistic_report_result
    cookies['user'] = @agent.access_token
    get "/api/v1/users/reports/statistics"
    statistic_report = JSON.parse(@response.body)
    assert_equal @order.amount, statistic_report["data"][1]["reports"][0]["unsettled"]
  end

  def test_player_login
    cookies['user'] = @member.access_token
    get "/api/v1/users/reports/statistics"
    statistic_report = JSON.parse(@response.body)
    hash = {}
    assert_equal hash, statistic_report
  end
end
