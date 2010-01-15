require File.dirname(__FILE__) + '/../test_helper'
require 'guesses_controller'

# Re-raise errors caught by the controller.
class GuessesController; def rescue_action(e) raise e end; end

class GuessesControllerTest < Test::Unit::TestCase
  fixtures :guesses

  def setup
    @controller = GuessesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:guesses)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:guess)
    assert assigns(:guess).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:guess)
  end

  def test_create
    num_guesses = Guess.count

    post :create, :guess => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_guesses + 1, Guess.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:guess)
    assert assigns(:guess).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Guess.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Guess.find(1)
    }
  end
end
