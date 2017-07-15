class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def attrs(*keys)
    attributes.symbolize_keys.select { |key, _| keys.include?(key) }
  end
end
