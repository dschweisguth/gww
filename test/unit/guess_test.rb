require File.dirname(__FILE__) + '/../test_helper'

class GuessTest < Test::Unit::TestCase
  def setup
    person1 = Person.new
    person1.flickrid = "flickrid1"
    person1.username = "username1"
    person1.save

    person2 = Person.new
    person2.flickrid = "flickrid2"
    person2.username = "username2"
    person2.save

    now = Time.now

    photo1 = Photo.new
    photo1.flickrid = "flickrid1"
    photo1.secret = "secret1"
    photo1.server = "server1"
    photo1.dateadded = 10.seconds.ago
    photo1.lastupdate = now
    photo1.seen_at = now
    photo1.game_status = "unfound"
    photo1.mapped = "false"
    photo1.person = person1
    photo1.farm = "farm1"
    photo1.save

    photo2 = Photo.new
    photo2.flickrid = "flickrid2"
    photo2.secret = "secret2"
    photo2.server = "server2"
    photo2.dateadded = 5.seconds.ago
    photo2.lastupdate = now
    photo2.seen_at = now
    photo2.game_status = "unfound"
    photo2.mapped = "false"
    photo2.person = person2
    photo2.farm = "farm2"
    photo2.save

    @guess1 = Guess.new
    @guess1.person = person1
    @guess1.photo = photo2
    @guess1.guessed_at = now
    @guess1.added_at = now
    @guess1.save

    @guess2 = Guess.new
    @guess2.person = person2
    @guess2.photo = photo1
    @guess2.guessed_at = now
    @guess2.added_at = now
    @guess2.save

  end

  def test_longest
    assert_equal [ @guess2, @guess1 ], Guess.longest
  end

  def test_shortest
    assert_equal [ @guess1, @guess2 ], Guess.shortest
  end

end
