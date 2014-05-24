class ActiveRecord::Base
  def self.only_one_exists
    all_instances = all
    if all_instances.length != 1
      raise RSpec::Expectations::ExpectationNotMetError,
        "Expected there to be only 1 #{self.name} instance, but there are #{all_instances.length}"
    end
    all_instances.first
  end
end
