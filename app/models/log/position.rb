class Log::Position < ApplicationRecord
  belongs_to :order, optional: true
end
