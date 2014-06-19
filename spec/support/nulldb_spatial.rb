# Patch nulldb to not explode on spatial columns in schema.rb

# It would be nice to patch only ActiveRecord::ConnectionAdapters::NullDBAdapter::TableDefinition, but that's
# just a reference to ActiveRecord::ConnectionAdapters::TableDefinition. Might as well make that clear here.
class ActiveRecord::ConnectionAdapters::TableDefinition
  def spatial(*args)
    options = args.extract_options!
    column_names = args
    column_names.each { |name| column(name, :spatial, options) }
  end
end

class ActiveRecord::ConnectionAdapters::NullDBAdapter
  alias_method :old_add_index_options, :add_index_options
  def add_index_options(table_name, column_name, options = {})
    # We only use this adapter to prevent us from using the database, so we don't care whether the SQL is correct.
    # Just drop the :spatial option so ActiveRecord code doesn't raise an error.
    old_add_index_options table_name, column_name, options.reject { |key, _| key == :spatial }
  end
end
