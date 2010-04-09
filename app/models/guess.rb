class Guess < ActiveRecord::Base

  belongs_to :photo
  belongs_to :person

  def self.longest
    Guess.find :all, :include => [ :photo ],
      :order => "guesses.guessed_at - photos.dateadded desc", :limit => 10
  end

  def self.shortest
    Guess.find :all, :include => [ :photo ],
      :order => "if(guesses.guessed_at - photos.dateadded > 0, guesses.guessed_at - photos.dateadded, 3600)",
      :limit => 10
  end

end
