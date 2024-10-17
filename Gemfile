# frozen_string_literal: true

source 'https://rubygems.org/'

gem 'actionpack-page_caching'
# See https://github.com/rgeo/activerecord-mysql2spatial-adapter/issues/12
gem 'activerecord-mysql2spatial-adapter', git: 'https://github.com/dschweisguth/activerecord-mysql2spatial-adapter.git',
  branch: 'v0.5.2-ar-4.2-mysql2-0.4-mysql-8-compatibility'
gem 'american_date'
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 5.0' # JQuery UI 6 sets up functions in a way that PhantomJS can't handle
gem 'mini_racer'
gem 'mysql2'
gem 'nokogiri'
gem 'rails', '~> 4.2.0'
# See https://github.com/rgeo/rgeo-activerecord/issues/23
gem 'rgeo-activerecord', git: 'https://github.com/dschweisguth/rgeo-activerecord.git', tag: 'v2.1.1-dump-schema'
gem 'sass-rails'
gem 'sprockets', '~> 3.7' # 4.0 requires a manifest which I don't feel like writing right now
gem 'uglifier'
gem 'warning'
gem 'will_paginate'
gem 'xml-simple'

group :development do
  gem 'rubocop', '~> 0.52.0' # yoked to .codeclimate.yml
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
  gem 'jasmine'
  gem 'launchy'
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'poltergeist'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end

group :production do
  gem 'passenger'
end
