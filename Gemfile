source 'http://rubygems.org/'
source 'http://gemcutter.org'

gem 'mysql2', '~> 0.2.6'
gem 'rails', '~> 2.3.10' 
gem 'will_paginate', '~> 2.3.15'
gem 'xml-simple', '~> 1.0.14'

# The following gem is in the default group because we
# use the production workspace when recreating TeamCity's copy of the test
# database (bundle exec rake RAILS_ENV=test db:drop db:create
# db:test:clone_structure) and referring to db:test drags in rspec.
gem 'rspec-rails', '~> 1.3.3'

group :test do
  gem 'rcov', '~> 0.9.9'
  gem 'rr', '~> 1.0.2'
  gem 'shoulda', '~> 2.11.3'
end

group :production do
  #noinspection RailsParamDefResolve,GemInspection
  gem 'passenger', '~> 3.0.2'
end
