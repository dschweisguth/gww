require 'simplecov'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'nulldb_rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  # config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  # Prevent database usage in these spec types. Note that :lib and :service are not standard rspec-rails types,
  # so specs of those layers must be manually tagged for this mechanism to work with them.
  %i(lib service controller helper routing).each do |type|
    config.include NullDB::RSpec::NullifiedDatabase, type: type

    config.after :each, type: type do
      begin
        ActiveRecord::Base.connection.should_not have_executed(:anything)
      rescue RSpec::Expectations::ExpectationNotMetError
        raise RSpec::Expectations::ExpectationNotMetError,
          "Database usage is forbidden in #{type} specs, but these SQL statements were executed: " +
            %Q("#{ActiveRecord::Base.connection.execution_log_since_checkpoint.map(&:content).join '", "'}")
      end
    end

  end

  # Prevent FlickrService usage
  config.before :each do
    allow(FlickrService).to receive(:instance).and_return(MockFlickrService.new)
  end

  [GWW::Factories::Model, GWW::Matchers::Model, GWW::Helpers::Model, GWW::Helpers::PageCache].each { |mod| config.include mod, type: :model }
  [GWW::Factories::ControllerOrHelper, GWW::Helpers::Controller, GWW::Helpers::PageCache, Photos].each { |mod| config.include mod, type: :controller }
  [GWW::Factories::ControllerOrHelper, Photos].each { |mod| config.include mod, type: :helper }
  config.include GWW::Matchers::Routing, type: :routing

end
