require 'ostruct'

class ApplicationJob < ActiveJob::Base
  def self.perform_by_env(*args)
    case Rails.env
    when 'development', 'production'
      perform_later(*args)
    when 'test'
      OpenStruct.new do
        def job_id
          "now"
        end

        def result
          perform_now(*args)
        end
      end
    end
  end
end
