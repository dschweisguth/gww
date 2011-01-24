# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'

# Uncomment the next line to use webrat's matchers
#require 'webrat/integrations/rspec-rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses its own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end

class Hash
  def -(*keys)
    #noinspection RubyUnusedLocalVariable
    reject { |key, value| keys.include?(key) }
  end
end

class Person
  def self.create_for_test(options)
    options, prefix, padded_prefix = process_prefix! options
    Person.create! :flickrid => padded_prefix + 'person_flickrid',
      :username => padded_prefix + 'username'
  end
end

class Photo
  def self.create_for_test(caller_options)
    caller_options, prefix, padded_prefix = process_prefix! caller_options
    now = Time.now
    poster = Person.create_for_test :prefix => (padded_prefix + 'poster')
    options = { :person => poster, :flickrid => prefix + 'photo_flickrid',
      :farm => 'farm', :server => 'server', :secret => 'secret',
      :dateadded => now, :lastupdate => now, :seen_at => now,
      :mapped => 'false', :game_status => 'unfound', :views => 0 }
    options.merge! caller_options
    Photo.create! options
  end
end

class Guess
  def self.create_for_test(caller_options)
    caller_options, prefix, padded_prefix = process_prefix! caller_options
    now = Time.now
    guesser = Person.create_for_test :prefix => (padded_prefix + 'guesser')
    options = { :person => guesser,
      :guess_text => "guess text", :guessed_at => now, :added_at => now }
    if ! caller_options[:photo]
      options[:photo] = Photo.create_for_test :prefix => prefix
    end
    options.merge! caller_options
    Guess.create! options
  end
end

def process_prefix!(options)
  prefix = options[:prefix]
  if prefix
    options.delete :prefix
  else
    prefix = ''
  end
  padded_prefix = prefix == '' ? '' : prefix + '_';
  return options, prefix, padded_prefix
end
