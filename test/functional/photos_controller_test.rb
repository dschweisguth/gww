require File.dirname(__FILE__) + '/../test_helper'
require 'photos_controller'

# Re-raise errors caught by the controller.
class PhotosController; def rescue_action(e) raise e end; end

class PhotosControllerTest < Test::Unit::TestCase
  fixtures :photos

  def setup
    @controller = PhotosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    person = Person.new
    person.save

    photo = Photo.new
    photo.id = 666 # TODO necessary?
    photo.lastupdate = Time.new.to_i
    photo.seen_at = Time.new.to_i
    photo.dateadded = Time.new.to_i
    photo.person = person
    photo.save

    get :show, :id => photo.id

    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:photo)
    assert assigns(:photo).valid?
    # TODO assert other stuff in model

  end

  def test_destroy
    assert_not_nil Photo.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'unverified'

    assert_raise(ActiveRecord::RecordNotFound) {
      Photo.find(1)
    }
  end

end
