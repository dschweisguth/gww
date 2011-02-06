require 'test_helper'

class Admin::PhotosControllerTest < ActionController::TestCase
  def setup
    @controller = Admin::PhotosController.new
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
    @photo.dateadded = Time.new
    @photo.lastupdate = Time.new
    @photo.seen_at = Time.new
    @photo.game_status = "unfound"
    @photo.mapped = "false"
    @photo.person = person
    @photo.farm = "farm"
    @photo.views = 0
    @photo.save

  end

  def test_destroy
    assert_not_nil Photo.find(@photo.id)

    post :destroy, :id => @photo.id
    assert_response :redirect
    assert_redirected_to admin_root_path

    assert_raise(ActiveRecord::RecordNotFound) {
      Photo.find(@photo.id)
    }

  end

end
