require 'capybara/poltergeist'

Capybara.server = :webrick
Capybara.javascript_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    js_errors: true,
    phantomjs: Phantomjs.path,
    phantomjs_options: ['--load-images=no'] # Don't load images in tests. It takes time and doesn't catch any errors.
  )
end
