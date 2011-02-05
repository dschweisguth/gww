require 'spec_helper'

describe Admin::PhotosController do
  describe '.update_statistics' do
    it 'does some work and redirects to the admin index' do
      mock(Photo).update_statistics
      any_instance_of(Admin::PhotosController) { |i| stub(i).expire_cached_pages }
      get :update_statistics
      #noinspection RubyResolve
      response.should redirect_to admin_root_path
      flash[:notice].should == 'Updated statistics.</br>'
    end
  end

end
