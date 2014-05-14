# This application's database schema can only be correctly represented in SQL,
# not in Ruby. This file adjusts existing Rake tasks to support this.
#
# Do not use db:migrate:reset. It does not do the right thing for this application,
# does not seem to fill a need and has not been adjusted to meet this application's needs.
#
# Note that config/application.rb does not set ActiveRecord's schema format to
# :sql. That's because
# - none of the rake tasks actually used by GWW to manage databases use that
#   setting, and
# - RubyMine gets the model structure from the Ruby schema, so it is still
#   useful to keep the Ruby schema up to date. Leaving the schema format set
#   to :ruby results in the Ruby schema being generated when a migration runs
#   or is rolled back.

# TODO this might all be obsolete after upgrading to Rails 4. Review the next time we have a migration.

namespace :db do

  # namespace :structure do
  #   task load: :environment do
  #     ActiveRecord::Base.establish_connection Rails.env
  #     ActiveRecord::Base.connection.execute 'SET foreign_key_checks = 0'
  #     IO.readlines("#{Rails.root}/db/structure.sql").join.split("\n\n").each do |statement|
  #       ActiveRecord::Base.connection.execute statement
  #     end
  #   end
  # end

  # # This changes the original to migrate, since structure.sql does not necessarily include all migrations.
  # Rake::Task['db:setup'].clear
  # task setup: %w(db:structure:load_if_sql db:migrate db:seed)

end

# namespace :test do
#   desc "rspec tasks depend on this task, so we override it to set up the database in the way that we want."
#   Rake::Task['test:prepare'].clear
#   task prepare: [ 'db:test:prepare', 'db:test:load', 'db:migrate', 'db:seed' ]
# end
