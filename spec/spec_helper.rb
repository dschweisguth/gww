require 'simplecov'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rr'
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

  config.include FactoryGirl::Syntax::Methods

  config.infer_spec_type_from_file_location!

  config.include GWW::Matchers::Model, type: :model
  config.include GWW::Matchers::Routing, type: :routing
  config.include Photos, type: :helper
  config.include Photos, type: :controller
  %i(controller helper lib routing service support).each do |type|
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

  config.before :each do
    # noinspection RubyArgCount
    stub(FlickrService).instance.returns MockFlickrService.new
  end

end
