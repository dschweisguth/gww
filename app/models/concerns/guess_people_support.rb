module GuessPeopleSupport
  extend ActiveSupport::Concern

  included do
    # Not persisted, used in views
    attr_accessor :place
  end

  module ClassMethods

    def mapped_count(person_id)
      where(person_id: person_id)
        .joins(:photo).where('photos.accuracy >= 12 || photos.inferred_latitude is not null')
        .count
    end

    def find_with_associations(person)
      where(person_id: person).includes(photo: :person)
    end

  end

end
