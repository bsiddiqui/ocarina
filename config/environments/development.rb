Ocarina::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Email Options
  config.smtp_user_name = ENV['SMTP_USER_NAME'] || 'matt@simpler.io'
  config.smtp_password  = ENV['SMTP_PASSWORD'] || 'jarpadarp'

  # API URLs
  config.web_url        = ENV['WEB_URL'] || 'http://localhost:4400'
  config.mobile_web_url = ENV['MOBILE_WEB_URL'] || 'http://localhost:8000'

  ##
  # CORS support
  config.middleware.insert_before "ActionDispatch::Static", "Rack::Cors", :debug => true, :logger => Rails.logger do
    allow do
      origins Rails.configuration.mobile_web_url

      resource '/api/*', 
        headers: :any,
        methods: [:get, :post]
    end
  end

end
