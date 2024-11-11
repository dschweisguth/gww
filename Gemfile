# frozen_string_literal: true

source 'https://rubygems.org/'

gem 'actionpack-page_caching'
# See https://github.com/rgeo/activerecord-mysql2spatial-adapter/issues/12
gem 'activerecord-mysql2spatial-adapter', git: 'https://github.com/dschweisguth/activerecord-mysql2spatial-adapter.git',
  branch: 'v0.5.2-ar-4.2-mysql2-0.4-mysql-8-compatibility'
gem 'american_date'
gem 'dotenv-rails', '~> 2.8.1'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'json', '~> 2.7' # without this, cucumber features use the default version and fail
gem 'mysql2'
gem 'nokogiri'
gem 'rails', '~> 4.2.0'
# See https://github.com/rgeo/rgeo-activerecord/issues/23
gem 'rgeo-activerecord', git: 'https://github.com/dschweisguth/rgeo-activerecord.git', tag: 'v2.1.1-dump-schema'
gem 'sprockets'
gem 'terser'
gem 'warning'
gem 'will_paginate'
gem 'xml-simple'

group :development do
  gem 'brakeman'
  gem 'irb'
  gem 'rubocop', '~> 1.50.2' # yoked to Code Climate
  gem 'rubocop-rspec'
  gem 'spring', '~> 2.1' # spring 3 requires Rails 5
  gem 'spring-commands-cucumber'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'activerecord-nulldb-adapter', '0.3.8'
  gem 'capybara'
  gem 'cucumber-rails', '~> 2.1.0', require: false # 2.2 requires Rails 5
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'timecop'
end

group :production do
  gem 'passenger'
  gem 'sass-rails'
end

group :test, :production do
  # Work around https://github.com/ffi/ffi/issues/1103 in test Github action
  gem 'ffi', '~> 1.16.3'
end
