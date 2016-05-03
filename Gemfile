source 'http://rubygems.org/'

gem 'actionpack-page_caching'
gem 'activerecord-mysql2spatial-adapter'
gem 'american_date'
gem 'foreigner'
gem 'jquery-rails', '~> 3.1.4' # 4.* requires Rails 4.2
gem 'jquery-ui-rails'
gem 'mysql2', '~> 0.3.20' # 0.4 requires Rails 4.2
gem 'rails', '~> 4.1.15'
gem 'sass-rails'
gem 'therubyracer', platforms: :ruby
gem 'uglifier'
gem 'will_paginate'
gem 'xml-simple'

group :development do
  gem 'rubocop'
  gem 'spring'
  gem 'spring-commands-cucumber'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'activerecord-nulldb-adapter'
  gem 'capybara'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'jasmine'
  gem 'launchy'
  gem 'phantomjs', '1.9.8' # Used by jasmine. This is the most recent version available from MacPorts.
  gem 'poltergeist'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end

group :production do
  gem 'passenger', '5.0.23'
end
