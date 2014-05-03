source 'http://rubygems.org/'

# mysql2 0.3.* requires Rails 3.1
gem 'mysql2', '0.2.18'
gem 'activerecord-mysql2spatial-adapter', '0.4.2'
gem 'rails', '3.0.20'
gem 'jquery-rails', '1.0.19'
gem 'will_paginate', '3.0.pre2' # Don't upgrade this without testing all uses. Later versions remove the ability to paginate a list of IDs.
gem 'xml-simple', '1.1.1'

group :test do
  gem 'capybara', '2.2.1'
  gem 'cucumber-rails', '1.4.0', require: false
  gem 'database_cleaner', '1.2.0'
  gem 'factory_girl_rails', '4.4.1'
  gem 'jasmine', '1.1.0'
  gem 'launchy', '2.4.2'
  gem 'poltergeist', '1.5.0'
  gem 'rr', '1.1.2', require: false
  gem 'shoulda-matchers', '1.1.0'
  gem 'simplecov', '0.7.1', require: false
  gem 'rspec-rails', '2.10.1'
end

group :production do
  gem 'passenger', '4.0.41'
end
