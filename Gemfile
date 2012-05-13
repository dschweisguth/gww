source 'http://rubygems.org/'

# mysql2 0.3.* requires Rails 3.1
gem 'mysql2', '0.2.18'
gem 'activerecord-mysql2spatial-adapter', '0.4.2'
gem 'rails', '3.0.12'
gem 'jquery-rails', '1.0.16'
gem 'rails3-jquery-autocomplete', '1.0.4'
gem 'will_paginate', '3.0.pre2'
gem 'xml-simple', '1.1.0'

# The following gem is in the default group
# 1) because we
# use the production workspace when recreating TeamCity's copy of the test
# database (bundle exec rake RAILS_ENV=test db:drop db:create
# db:test:clone_structure) and referring to db:test drags in rspec
# 2) because
#    http://blog.davidchelimsky.net/2010/07/11/rspec-rails-2-generators-and-rake-tasks/
#    http://blog.davidchelimsky.net/2010/07/11/rspec-rails-2-generators-and-rake-tasks-part-ii/
group :development do
  gem 'rspec-rails', '2.6.1'
end

group :test do
  gem 'jasmine', '1.1.0'
  gem 'rr', '1.0.4'
  gem 'shoulda-matchers', '1.0.0.beta2'
  gem 'simplecov', '0.5.3'
  gem 'rspec-rails', '2.6.1'
  gem 'webrat', '0.7.3'
end

group :production do
  gem 'passenger', '3.0.7'
end
