# Monkey-patch NullDB to 'support' a method called by active_record 4.2
class ActiveRecord::ConnectionAdapters::NullDBAdapter::Column
  def case_sensitive?
    false
  end
end

module NullDB::RSpec::NullifiedDatabase
  class HaveExecuted
    # Provide the method name specified by RSpec 3 to suppress deprecation warning
    alias_method :failure_message_when_negated, :negative_failure_message
  end
end
