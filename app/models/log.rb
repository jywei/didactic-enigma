# 底下儲存所有相關的 Log 例如 Log::Push, Log::Error 等等
module Log
  def self.table_name_prefix
    'log_'
  end
end
