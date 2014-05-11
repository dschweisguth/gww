# Map fixtures directory for Jasmine suite.
# See routes.rb and https://github.com/travisjeffery/jasmine-jquery-rails/issues/4
if defined? Jasmine::Jquery::Rails::Engine
  JasmineFixtureServer = Proc.new do |env|
    Rack::Directory.new('spec/javascripts/fixtures').call(env)
  end
end
