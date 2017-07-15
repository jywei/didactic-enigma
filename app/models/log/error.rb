require 'slack-notifier'

# 程式錯誤紀錄
class Log::Error < ApplicationRecord
  belongs_to :user, optional: true

  serialize :backtrace
  serialize :data
  serialize :params, Hash

  scope :with_data, ->() { includes(:user) }
  scope :now, ->() { order('id DESC').where("created_at > ?", Time.now - 5.minutes) }
  scope :recent,  ->() { order('id DESC').where("created_at > ?", Time.now - 1.day) }
  scope :history, ->() { order('id DESC').where("created_at < ?", Time.now - 1.day) }

  after_create :notify_if_new

  attr_accessor :count

  # 發生錯誤時主動發送通知至slack
  def notify_if_new
    return unless Rails.env.production?
    errors_now = self.class.now.where(name: name, path: path).where.not(id: self.id)
    if errors_now.empty?
      host = "http://52.192.25.216:3000"
      m = "程式錯誤\n[#{name}](#{host}/logs/errors/#{id}): #{message}. \n路徑：[#{path}](#{host}#{path})\n使用者：#{user.try(:username)}" 
      formatted = Slack::Notifier::LinkFormatter.format(m)
      $notifier.ping(formatted)
    end
  end

  # 整理目前where出來的所有log，將相同內容的合併，並加上count欄位
  def self.stack
    temp   = all.dup.map {|log| log.count = 1 ; log }

    result = []
    temp.each do |log|
      duplicate = result.select {|n| 
        n[:name] == log[:name] && n[:path] == log[:path] && n[:message] == log[:message]
      }.first

      duplicate ? duplicate.count += 1 : result << log
    end

    result
  end
end
