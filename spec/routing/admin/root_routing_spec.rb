describe Admin::RootController do

  describe 'index' do
    it { has_named_route :admin_root, '/admin' }
    it { is_expected.to route(:get, '/admin').to controller: 'admin/root', action: 'index' }
  end

  %w{ update_from_flickr calculate_statistics_and_maps }.each do |action|
    describe action do
      it { has_named_route action, "/admin/#{action}" }
      it { is_expected.to route(:post, "/admin/#{action}").to controller: 'admin/root', action: action }
    end
  end

  describe 'bookmarklet' do
    it { has_named_route :admin_root_bookmarklet, '/admin/bookmarklet' }
    it { is_expected.to route(:get, '/admin/bookmarklet').to controller: 'admin/root', action: 'bookmarklet' }
  end

end
