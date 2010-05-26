require 'test_helper'

class PeopleHelperTest < ActionView::TestCase

  def test_position_first
    first_place = person 1
    high_scorers = [ first_place ]
    assert_equal '', position(high_scorers, first_place)
  end

  def test_position_first_tie
    first_place_2 = person 1
    high_scorers = [ person(1), first_place_2 ]
    assert_equal '', position(high_scorers, first_place_2)
  end

  def test_position_second
    second_place = person 1
    high_scorers = [ person(2), second_place ]
    assert_equal 'second-', position(high_scorers, second_place)
  end

  def test_position_third
    third_place = person 1
    high_scorers = [ person(3), person(2), third_place ]
    assert_equal 'third-', position(high_scorers, third_place)
  end

  def test_position_third_tie
    third_place = person 1
    high_scorers = [ person(2), person(1), third_place ]
    assert_equal 'second-', position(high_scorers, third_place)
  end

  def person(score)
    person = Person.new
    person[:score] = score
    person
  end

end
