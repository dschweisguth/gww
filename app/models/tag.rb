class Tag < ActiveRecord::Base
  belongs_to :photo, inverse_of: :tags

  # TODO Dave constrain

end
