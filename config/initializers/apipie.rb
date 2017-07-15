Apipie.configure do |config|
  config.app_name                = "博林控台API"
  config.doc_base_url            = "/docs/api"
  config.reload_controllers      = Rails.env.development?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/v1/**/*.rb"
  config.app_info["0.0.1"]       = ""
  config.default_version         = "0.0.1"
  config.api_base_url            = "/api/v1"
end
