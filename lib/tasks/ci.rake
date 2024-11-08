# This task does everything that needs to be done to run tests in CI that can be done in rake,
# i.e. everything except 'bundle --deployment --without production', which is done in a previous TeamCity build step.
# It would be nicer to have a script that bundles and then runs this task that could be run in CI in a single step,
# but TeamCity can report RSpec and Cucumber results only from a rake step.
task ci: ['ci:config', 'db:reset', 'db:schema:dump', :default]

namespace :ci do
  task :config do
    FileUtils.cp "#{Dir.home}/lib/TeamCity-config/.env", '.'
  end
end
