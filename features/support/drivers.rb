require 'selenium/webdriver/firefox'

Capybara.server = :webrick

firefox_path = "/Applications/Firefox.app/Contents/MacOS/firefox"
if File.exist? firefox_path
  Selenium::WebDriver::Firefox::path = firefox_path
end
# Register driver constructed with capabilities: rather than deprecated options:
capabilities = Selenium::WebDriver::Firefox::Options.new.tap { |opts| opts.add_argument '-headless' }
Capybara.register_driver :endorsed_selenum_headless do |app|
  Capybara::Selenium::Driver.new(app, browser: :firefox, capabilities: capabilities)
end
Capybara.javascript_driver = :endorsed_selenum_headless
