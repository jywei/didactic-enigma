require 'test_helper'

class Log::PushTest < ActiveSupport::TestCase

  def setup
    create(:log_push, :drop, created_at: '2016-12-30')
    create(:log_push, :drop, event: 'event', created_at: '2016-12-30')
    create(:log_push, :drop, action: 'update', created_at: '2016-12-30')
    @log      = create(:log_push, action: 'update', created_at: "2017-01-06")
    @log_drop = create(:log_push, :drop, created_at: "2017-01-06")
  end

  def push_log
    @push_log ||= Log::Push.new
  end

  def test_vilid
    assert push_log.valid?
  end

  def search_column(column, value)
    case column
    when 'event'
      @logs.select {|log| log.event == value }
    when 'action'
      @logs.select {|log| log.action == value }
    when 'id'
      @logs.select {|log| log.id == value }
    end
  end

  def test_search_log_event_and_actions
    @logs = Log::Push.all.search(
      event:   'offer',
      actions: 'update'
    )
    assert_operator search_column('event', 'offer').size, :>,  0
    assert_operator search_column('event', 'event').size, :==, 0
    assert_operator search_column('action', 'update').size, :>,  0
    assert_operator search_column('action', 'drop').size, :==, 0
    assert_operator search_column('id', @logs.first.id).size, :>,  0
    assert_operator search_column('id', @log.id).size, :>, 0
  end

  def test_search_log_date
    @logs = Log::Push.all.search(
      date_start: '2016-12-29',
      date_end:   '2016-12-31'
    )
    assert_operator search_column('id', @log.id).size, :==, 0
    assert_operator search_column('id', @log_drop.id).size, :==, 0
  end
end
