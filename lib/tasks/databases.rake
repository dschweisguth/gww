# This application's database schema can only be correctly represented in SQL,
# not in Ruby. This file adjusts existing Rake tasks to support this.
#
# Do not use test:prepare or db:test:prepare. They do not do the right thing
# for this application, do not seem to fill a need and have not been adjusted
# to meet this application's needs.
#
# Note that config/application.rb does not set ActiveRecord's schema format to
# :sql. That's because
# - none of the rake tasks actually used by GWW to manage databases use that
#   setting, and
# - RubyMine gets the model structure from the Ruby schema, so it is still
#   useful to keep the Ruby schema up to date. Leaving the schema format set
#   to :ruby results in the Ruby schema being generated when a migration runs
#   or is rolled back.
namespace :db do

  namespace :structure do
    task :load => :environment do
      ActiveRecord::Base.establish_connection Rails.env
      ActiveRecord::Base.connection.execute 'SET foreign_key_checks = 0'
      IO.readlines("#{Rails.root}/db/#{Rails.env}_structure.sql").join.split("\n\n").each do |table|
        ActiveRecord::Base.connection.execute table
      end
    end
  end

  namespace :migrate do
    # We override the original of this task for consistency. Like the original, it doesn't seed.
    Rake::Task['db:migrate:reset'].clear
    task :reset => [ 'db:drop', 'db:create', 'db:structure:load', 'db:migrate' ]
  end

  # This overrides the original, which does db:schema:load. The original doesn't migrate; this version does,
  # since, unlike schema.rb, *_structure.sql does not necessarily include all migrations.
  Rake::Task['db:setup'].clear
  task :setup => [ 'db:create', 'db:structure:load', 'db:migrate', 'db:seed' ]

end

# By default rspec recreates the test database from the development database.
# That's dumb, because a development database doesn't necessarily exist on the
# machine where we want to run tests (in continuous integration, for example),
# and if it did its schema might not be fit to run tests on (when developing a
# migration, for example). Prevent that.
Rake::Task[:spec].clear_prerequisites
