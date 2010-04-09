require File.dirname(__FILE__) + '/../test_helper'
require 'photos_controller'

# Re-raise errors caught by the controller.
class PhotosController; def rescue_action(e) raise e end; end

class PhotosControllerTest < Test::Unit::TestCase
  def setup
    @controller = PhotosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    person = Person.new
    person.flickrid = "flickrid"
    person.username = "username"
    person.save

    @photo = Photo.new
    @photo.flickrid = "flickrid"
    @photo.secret = "secret"
    @photo.server = "server"
    @photo.dateadded = Time.new.to_i
    @photo.lastupdate = Time.new.to_i
    @photo.seen_at = Time.new.to_i
    @photo.game_status = "unfound"
    @photo.mapped = "false"
    @photo.person = person
    @photo.farm = "farm"
    @photo.save

  end

  def test_show
    get :show, :id => @photo.id

    assert_response :success
    assert_template 'show'
    assert_not_nil assigns :photo
    assert assigns(:photo).valid?
    # TODO assert other stuff in model

  end

  def test_destroy
    assert_not_nil Photo.find @photo.id

    post :destroy, :id => @photo.id
    assert_response :redirect
    assert_redirected_to :action => 'unverified'

    assert_raise(ActiveRecord::RecordNotFound) {
      Photo.find @photo.id
    }
  end

end
