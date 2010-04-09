require File.dirname(__FILE__) + '/../test_helper'
require 'people_controller'

# Re-raise errors caught by the controller.
class PeopleController; def rescue_action(e) raise e end; end

class PeopleControllerTest < Test::Unit::TestCase
  def setup
    @controller = PeopleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns :people
  end

  def test_show
    person = Person.new
    person.flickrid = 'flickrid'
    person.username = 'username'
    person.save

    get :show, :id => person.id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns :person
    assert assigns(:person).valid?
  end

end
