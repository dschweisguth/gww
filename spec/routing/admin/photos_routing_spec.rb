require 'spec_helper'

describe Admin::PhotosController do
  without_transactions

  %w{ update_all_from_flickr update_statistics }.each do |action|
    describe action do
      it 'has a named route' do
        send("#{action}_path").should == "/admin/photos/#{action}"
      end

      it { should route(:post, "/admin/photos/#{action}").to :controller => 'admin/photos', :action => action }

    end
  end

  %w{ unfound inaccessible multipoint }.each do |action|
    describe action do
      it 'has a named route' do
        send("#{action}_admin_photos_path").should == "/admin/photos/#{action}"
      end

      it { should route(:get, "/admin/photos/#{action}").to :controller => 'admin/photos', :action => action }

    end
  end

  describe 'edit' do
    it 'has a named route' do
      #noinspection RubyResolve
      edit_admin_photo_path(666).should == '/admin/photos/666/edit'
    end

    it { should route(:get, '/admin/photos/666/edit').to :controller => 'admin/photos', :action => 'edit', :id => '666' }

  end

  %w{ change_game_status add_selected_answer add_entered_answer remove_revelation remove_guess reload_comments }.each do |action|
    describe action do
      it 'has a named route' do
        send("#{action}_path", 666).should == "/admin/photos/666/#{action}"
      end

      it { should route(:post, "/admin/photos/666/#{action}").to :controller => 'admin/photos', :action => action, :id => '666' }

    end
  end

  describe 'destroy' do
    it 'has a named route' do
      #noinspection RubyResolve
      admin_photo_path(666).should == '/admin/photos/666'
    end

    it { should route(:delete, "/admin/photos/666").to :controller => 'admin/photos', :action => 'destroy', :id => '666' }

  end

  describe 'edit_in_gww' do
    it 'has a named route' do
      #noinspection RubyResolve
      edit_in_gww_path.should == '/admin/photos/edit_in_gww'
    end

    it { should route(:get, "/admin/photos/edit_in_gww").to :controller => 'admin/photos', :action => 'edit_in_gww' }

  end

end
