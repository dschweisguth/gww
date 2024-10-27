require File.expand_path('boot', __dir__)
require 'find'

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
# require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GWW
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = false

    config.autoload_paths << "#{config.root}/app/models/specialists"
    config.autoload_paths += Dir["#{config.root}/app/models/specialists/*"]

    config.active_record.schema_format = :sql

    # Put the following in application.rb so we can test it in development
    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    config.assets.precompile += %w(
      jquery-ui/autocomplete.css
      jquery-ui/core.css
      jquery-ui/menu.css
      jquery-ui/widgets/autocomplete.js
    )
    config.assets.precompile +=
      Find.find('vendor/assets/javascripts').select { |file| file.end_with? '.js' }.map { |file| file.sub %r(^vendor/assets/javascripts/), '' } +
        Find.find('app/assets/stylesheets').select { |file| file.end_with? '.css' }.map { |file| file.sub %r(^app/assets/stylesheets/), '' } +
        Find.find('app/assets/javascripts').select { |file| file.end_with? '.js' }.map { |file| file.sub %r(^app/assets/javascripts/), '' }

    config.colorize_logging = false

  end
end
