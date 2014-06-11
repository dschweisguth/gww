module GuessPeopleSupport
  extend ActiveSupport::Concern

  included do
    # Not persisted, used in views
    attr_accessor :place
  end

end
