class Person < ActiveRecord::Base
  has_many :photos
  has_many :guesses
end
