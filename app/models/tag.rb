class Tag < ActiveRecord::Base
  belongs_to :photo, inverse_of: :tags

  validates_presence_of :raw
  validates_uniqueness_of :raw, scope: :photo_id
  validates_inclusion_of :machine_tag, in: [false, true]

  attr_readonly :raw, :machine_tag

  def correct?
    !(raw.downcase == 'foundinsf' && photo.game_status != 'found' ||
      raw.downcase == 'unfoundinsf' && ! %w(unfound unconfirmed).include?(photo.game_status))
  end

end
