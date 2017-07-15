class CacheSetterJob < ApplicationJob
  queue_as :cache_setter

  def perform(type, options = {})
    Cache::Setter.new(type, options).run
  end
end
