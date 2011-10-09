require 'spec_helper'

describe Admin::RootController do

  describe 'index' do
    it { should have_named_route :admin_root, '/admin' }
    it { should route(:get, '/admin').to :controller => 'admin/root', :action => 'index' }
  end

  %w{ update_from_flickr calculate_statistics_and_maps }.each do |action|
    describe action do
      it { should have_named_route action, "/admin/#{action}" }
      it { should route(:post, "/admin/#{action}").to :controller => 'admin/root', :action => action }
    end
  end

  describe 'bookmarklet' do
    it { should have_named_route :admin_root_bookmarklet, '/admin/bookmarklet' }
    it { should route(:get, '/admin/bookmarklet').to :controller => 'admin/root', :action => 'bookmarklet' }
  end

end
