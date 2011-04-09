class Stcline < ActiveRecord::Base
  def self.street_names
    (order(:street).map &:street).uniq
  end
end
