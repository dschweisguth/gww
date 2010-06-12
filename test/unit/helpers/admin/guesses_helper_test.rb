require 'test_helper'

class Admin::GuessesHelperTest < ActionView::TestCase

  def test_escape_username_safe_1
    assert_equal 'KayVee . INC', escape_username('KayVee .INC')
  end

  def test_escape_username_safe_2
    assert_equal 'KayVee. INC', escape_username('KayVee. INC')
  end

  def test_escape_username_unsafe_1
    assert_equal 'KayVee . INC', escape_username('KayVee.INC')
  end

end
