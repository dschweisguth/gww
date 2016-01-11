SimpleCov.start 'rails' do
  # Undo simplecov's default configuration of ignoring coverage of test code. We want to know about dead code in tests.
  filters.reject! { |filter| %w(/spec/ /features/).include? filter.filter_argument.to_s }

  groups.delete 'Libraries' # simplecov's default Libraries group includes specs
  groups.delete 'Mailers'
  groups.delete 'Plugins'

  add_group('Libraries') { |src_file| src_file.filename.include?('/lib/') && !src_file.filename.include?('/spec/') }
  add_group 'Services', 'app/services/'
  add_group 'Updaters', 'app/updaters/'
  add_group 'Factories', 'factories/'
  add_group 'Specs', 'spec/'
  add_group 'Features', 'features/'

end
