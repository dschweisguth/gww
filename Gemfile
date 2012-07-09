source 'http://rubygems.org/'

# mysql2 0.3.* requires Rails 3.1
gem 'mysql2', '0.2.18'
gem 'activerecord-mysql2spatial-adapter', '0.4.2'
gem 'rails', '3.0.12'
gem 'jquery-rails', '1.0.19'
gem 'rails3-jquery-autocomplete', '1.0.7'
gem 'will_paginate', '3.0.pre2' # Don't upgrade this without testing all uses. Later versions remove the ability to paginate a list of IDs.
gem 'xml-simple', '1.1.1'

# The following gem is in the default group
# 1) because we
# use the production workspace when recreating TeamCity's copy of the test
# database (bundle exec rake RAILS_ENV=test db:drop db:create
# db:test:clone_structure) and referring to db:test drags in rspec
# 2) because
#    http://blog.davidchelimsky.net/2010/07/11/rspec-rails-2-generators-and-rake-tasks/
#    http://blog.davidchelimsky.net/2010/07/11/rspec-rails-2-generators-and-rake-tasks-part-ii/
group :development do
  gem 'rspec-rails', '2.10.1'
end

group :test do
  gem 'jasmine', '1.1.0'
  gem 'rr', '1.0.4'
  gem 'shoulda-matchers', '1.1.0'
  gem 'simplecov', '0.6.4'
  gem 'rspec-rails', '2.10.1'
  gem 'webrat', '0.7.3'
end

group :production do
  gem 'passenger', '3.0.12'
end
