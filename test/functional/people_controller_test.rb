require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  def setup
    @controller = PeopleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_list
    get :list, { :sorted_by => 'username', :order => '+' }

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:people)
  end

  def test_show
    person = Person.new
    person.flickrid = 'flickrid'
    person.username = 'username'
    person.save

    get :show, :id => person.id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:person)
    assert assigns(:person).valid?
  end

end
