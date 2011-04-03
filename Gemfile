source 'http://rubygems.org/'
source 'http://gemcutter.org'

gem 'mysql2', '0.2.6'
gem 'rails', '3.0.5'
gem 'jquery-rails', '0.2.7'
gem 'rails3-jquery-autocomplete', '0.6.3'
gem 'will_paginate', '3.0.pre2'
gem 'xml-simple', '1.0.14'

# The following gem is in the default group
# 1) because we
# use the production workspace when recreating TeamCity's copy of the test
# database (bundle exec rake RAILS_ENV=test db:drop db:create
# db:test:clone_structure) and referring to db:test drags in rspec
# 2) because
#    http://blog.davidchelimsky.net/2010/07/11/rspec-rails-2-generators-and-rake-tasks/
#    http://blog.davidchelimsky.net/2010/07/11/rspec-rails-2-generators-and-rake-tasks-part-ii/
group :development do
  gem 'rspec-rails', '2.5.0'
end

group :test do
  gem 'rcov', '0.9.9'
  gem 'rr', '1.0.2'
  gem 'shoulda-matchers', '1.0.0.beta2'
  gem 'rspec-rails', '2.5.0'
  gem 'webrat', '0.7.3'
end

group :production do
  #noinspection RailsParamDefResolve,GemInspection
  gem 'passenger', '3.0.5'
end
