class Person < ActiveRecord::Base
  has_many :photos
  has_many :guesses
  has_many :revelations
end
