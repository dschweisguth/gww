# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'nulldb_rspec'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Prevent database usage in these spec types. Note that :initializer, :service and :value are not standard rspec-rails
  # types, so specs of those layers must be manually tagged for this mechanism to work with them.
  %i(controller helper initializer routing service value).each do |type|
    config.include NullDB::RSpec::NullifiedDatabase, type: type

    config.after :example, type: type do
      begin
        expect(ActiveRecord::Base.connection).not_to have_executed(:anything)
      rescue RSpec::Expectations::ExpectationNotMetError
        raise RSpec::Expectations::ExpectationNotMetError,
          "Database usage is forbidden in #{type} specs, but these SQL statements were executed: " +
            %Q("#{ActiveRecord::Base.connection.execution_log_since_checkpoint.map(&:content).join '", "'}")
      end
    end

  end

  Shoulda::Matchers.configure do |shoulda|
    shoulda.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  # Prevent FlickrService usage
  config.before :example do
    allow(FlickrService).to receive(:instance).and_return(MockFlickrService.new)
  end

  config.render_views

  config.include GWW::Helpers::RSpec
  [GWW::Factories::Model, GWW::Matchers::Model, GWW::Helpers::Model, GWW::Helpers::PageCache].each { |mod| config.include mod, type: :model }
  [GWW::Factories::Model, GWW::Matchers::Model].each { |mod| config.include mod, type: :updater }
  [GWW::Factories::ControllerOrHelper, GWW::Helpers::Controller, GWW::Helpers::PageCache, Photos].each { |mod| config.include mod, type: :controller }
  [GWW::Factories::ControllerOrHelper, Photos].each { |mod| config.include mod, type: :helper }
  [GWW::Helpers::Routing, GWW::Matchers::Routing].each { |mod| config.include mod, type: :routing }

end
