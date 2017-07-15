# 提供worker在紀錄接收 tx push feed 使用，最後會在Go專案的worker/log內儲存為 Log::Push
#
#     # 產生新的log
#     log = Log::Push::Temp.new("offers", SecureRandom.uuid, {})
#
#     # 寫入過程
#     log.push("this is a book")
#
#     # 設定動作
#     log.action("update")
#
#     # 寫入錯誤
#     log.error("this is an error")
# 
class Log::Push::Temp < Hash
  attr_reader :uuid, :event
  
  def initialize(event = "", uuid = "", data = {})
    self[:data] = data
    self[:log] = ""
    self[:tx_timestamp] = data[:ts]
    self[:afu_timestamp] = DateTime.now.strftime("%Q")

    if data[:action_name].present?
      action(data[:action_name]) 
      data.delete(:action_name)
    end
    
    # Necessary attributes
    self[:event] = event
    @event = event
    self[:uuid] = uuid
    @uuid = uuid
  end

  # 紀錄過程
  def push(message)
    puts message if Rails.env != 'test'
    self[:log] << "- #{message}\n"
  end

  def assign_attributes(args)
    merge!(args)
  end

  def action(name)
    self[:action] = name
    push("Taking action: #{name}")
  end

  def error(e)
    self[:has_error] = 1
    push("#{e.class} #{e.message.gsub("'", "_")}")
    self[:action] = "no_action" if self[:action].blank?
    e.backtrace.each {|b| push("Backtrace: #{b.gsub("'", "_")}") }
  end

  def format
    %i(data tx_match tx_offer).each {|k| self[k] = self[k].to_json }
    self
  end

  def request(event, attrs)
    push("Requesting Event: #{event}")
    push("Requesting params: #{attrs.to_s}")
  end
end
