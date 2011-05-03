require 'rspec/core'
require 'rspec/core/rake_task'

Rake.application.instance_variable_get('@tasks').delete 'spec:rcov'

namespace :spec do
  desc "Run all specs with rcov"
  RSpec::Core::RakeTask.new(:rcov => 'db:test:prepare') do |t|
    t.rcov = true
    t.pattern = "./spec/**/*_spec.rb"
    t.rcov_opts = '--exclude /gems/,/Library/,/usr/,lib/tasks,.bundle,config,/lib/rspec/,/lib/rspec-,spec/,buildAgent/plugins'
  end
end
