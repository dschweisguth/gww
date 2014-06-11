module GuessPeopleSupport
  extend ActiveSupport::Concern

  included do
    # Not persisted, used in views
    attr_accessor :place
  end

  module ClassMethods

    def find_with_associations(person)
      where(person_id: person).includes(photo: :person)
    end

  end

end
