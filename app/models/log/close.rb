# 關盤的log，目前在正式機上有cron設定每小時將超過時間的比賽關盤一次，參考 lib/tasks/match/close.rake
class Log::Close < ApplicationRecord
  serialize :data
end
