# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  config.mock_with :rr
  # config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # shoulda-matchers should include itself, but the following include is
  # necessary for rake spec to pass.
  config.include Shoulda::Matchers::ActionController
  # shoulda-matchers should include itself, but the following include is
  # necessary for rake spec:rcov (but not rake spec!?!) to pass.
  config.include Shoulda::Matchers::ActiveRecord, :type => :model
  config.include Webrat::HaveTagMatcher, :type => :helper
  config.include Webrat::HaveTagMatcher, :type => :controller

  config.include GWW::Matchers::Model, :type => :model
  config.include GWW::Matchers::Routing, :type => :routing
  config.include Photos, :type => :helper
  config.include Photos, :type => :controller

end
