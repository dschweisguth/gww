# Possibly we should be able to require rspec/core, then rr, then cucumber/rspec/doubles (as in
# https://github.com/cucumber/cucumber/blob/master/examples/rspec_doubles/features/support/env.rb)
# instead of writing our own include and hooks, but I couldn't get that to work.

require 'rr/without_autohook'

World RR::Adapters::RRMethods

Before do
  RR::Space.instance.reset
end

After do
  begin
    RR::Space.instance.verify_doubles
  ensure
    RR::Space.instance.reset
  end
end
