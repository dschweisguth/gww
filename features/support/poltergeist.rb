require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
  # TODO Dave resume loading images in tests after migrating to staticflickr.com
  Capybara::Poltergeist::Driver.new app, js_errors: true, phantomjs_options: ['--load-images=no']
end
