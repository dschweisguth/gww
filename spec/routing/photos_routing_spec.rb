require 'spec_helper'

describe PhotosController do

  describe 'index' do
    it { should have_named_route :photos, 'foo', 'bar', 1, '/photos/sorted-by/foo/order/bar/page/1' }
    it { should route(:get, '/photos/sorted-by/foo/order/bar/page/1').to(
      :controller => 'photos', :action => 'index', :sorted_by => 'foo', :order => 'bar', :page => '1') }
  end

  %w{ map unfound unfound_data }.each do |action|
    describe action do
      it { should have_named_route "#{action}_photos", "/photos/#{action}" }
      it { should route(:get, "/photos/#{action}").to :controller => 'photos', :action => action }
    end
  end

  describe 'show' do
    it { should have_named_route :photo, 666, '/photos/666' }
    it { should route(:get, '/photos/666').to :controller => 'photos', :action => 'show', :id => '666' }
  end

  describe 'map_popup' do
    it { should have_named_route :map_popup_photo, 666, '/photos/666/map_popup' }
    it { should route(:get, '/photos/666/map_popup').to :controller => 'photos', :action => 'map_popup', :id => '666' }
  end

end
