# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'
# TODO Dave there must be a better way to add environment-specific bits to rake
if RAILS_ENV != 'production'
  require 'rcov/rcovtask'

  # From http://eigenclass.org/hiki/rcov+FAQ
  namespace :test do
    namespace :coverage do
      desc "Delete aggregate coverage data."
      task(:clean) { rm_f "coverage.data" }
    end
    desc 'Aggregate code coverage for unit, functional and integration tests'
    task :coverage => "test:coverage:clean"
    %w[functional].each do |target|
      namespace :coverage do
        Rcov::RcovTask.new(target) do |t|
          t.libs << "test"
          t.test_files = FileList["test/#{target}/**/*_test.rb"]
          t.output_dir = "test/coverage/#{target}"
          t.rcov_opts << '--rails --aggregate coverage.data --exclude "gems/*,plugins/*"'
        end
      end
      task :coverage => "test:coverage:#{target}"
    end
  end

  task :tests_and_specs => ['test:coverage', 'spec:rcov']

end
