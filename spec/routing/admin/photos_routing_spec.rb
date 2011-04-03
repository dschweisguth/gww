require 'spec_helper'

describe Admin::PhotosController do
  without_transactions

  describe 'auto_complete_person_username' do
    it { should have_named_route :admin_photos_autocomplete_person_username, "/admin/photos/autocomplete_person_username" }
    it { should route(:get, '/admin/photos/autocomplete_person_username').to :controller => 'admin/photos', :action => 'autocomplete_person_username' }
  end

  %w{ update_all_from_flickr update_statistics }.each do |action|
    describe action do
      it { should have_named_route action, "/admin/photos/#{action}" }
      it { should route(:post, "/admin/photos/#{action}").to :controller => 'admin/photos', :action => action }
    end
  end

  %w{ unfound inaccessible multipoint }.each do |action|
    describe action do
      it { should have_named_route "#{action}_admin_photos", "/admin/photos/#{action}" }
      it { should route(:get, "/admin/photos/#{action}").to :controller => 'admin/photos', :action => action }
    end
  end

  describe 'edit' do
    it { should have_named_route :edit_admin_photo, 666, '/admin/photos/666/edit' }
    it { should route(:get, '/admin/photos/666/edit').to :controller => 'admin/photos', :action => 'edit', :id => '666' }
  end

  %w{ change_game_status add_selected_answer add_entered_answer remove_revelation remove_guess reload_comments }.each do |action|
    describe action do
      it { should have_named_route action, 666, "/admin/photos/666/#{action}" }
      it { should route(:post, "/admin/photos/666/#{action}").to :controller => 'admin/photos', :action => action, :id => '666' }
    end
  end

  describe 'destroy' do
    it { should have_named_route :admin_photo, 666, '/admin/photos/666' }
    it { should route(:delete, '/admin/photos/666').to :controller => 'admin/photos', :action => 'destroy', :id => '666' }
  end

  describe 'edit_in_gww' do
    it { should have_named_route :edit_in_gww, '/admin/photos/edit_in_gww' }
    it { should route(:get, '/admin/photos/edit_in_gww').to :controller => 'admin/photos', :action => 'edit_in_gww' }
  end

end
