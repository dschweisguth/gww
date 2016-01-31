require 'rspec/core'
require 'rspec/mocks'

require_relative '../../spec/support/expectations_and_mocks'

World(RSpec::Mocks::ExampleMethods)

Before do
  RSpec::Mocks.setup
end

After do
  begin
    RSpec::Mocks.verify
  ensure
    RSpec::Mocks.teardown
  end
end
