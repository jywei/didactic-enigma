require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.generators do |g|
      g.test_framework  :minitest, fixture: false
      g.stylesheets     false
      g.javascripts     false
    end

    config.active_job.queue_adapter = :resque

    config.time_zone = 'Asia/Taipei'
    config.active_record.time_zone_aware_types = [:datetime, :time]
    config.active_record.default_timezone = :local

    config.middleware.insert_before 0, Rack::Cors, debug: true, logger: (-> { Rails.logger }) do
      allow do
        origins '*'

        resource '/cors',
                 headers: :any,
                 methods: [:post],
                 credentials: true,
                 max_age: 0

        resource '*',
                 headers: :any,
                 methods: [:get, :post, :delete, :put, :patch, :options, :head],
                 max_age: 0
      end
    end

    config.eager_load_paths += ["#{Rails.root}/app/channels", "#{Rails.root}/lib/core_ext"]
    # Dir["#{Rails.root}/app/services/redis/**/*.rb", "#{Rails.root}/app/services/data/**/*.rb", "#{Rails.root}/app/services/operation/**/*.rb"].each { |file| require file }

    $notifier = Slack::Notifier.new('https://hooks.slack.com/services/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')
  end
end
