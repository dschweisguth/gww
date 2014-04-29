SimpleCov.start 'rails' do

  # Undo simplecov's default configuration of ignoring coverage of test code. We want to know about dead code in tests.
  filters.reject! { |filter| %q[ '/spec/', '/features/' ].include? filter.filter_argument.to_s }

  groups.delete 'Mailers'
  groups.delete 'Plugins'

  add_group 'Factories', 'factories/'
  add_group 'Features', 'features/'
  add_group 'Specs', 'spec/'

end
