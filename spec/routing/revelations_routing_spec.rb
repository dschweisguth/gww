describe RevelationsController do
  describe 'longest' do
    it { has_named_route? :longest_revelations, '/revelations/longest' }
    it { does route(:get, '/revelations/longest').to action: 'longest' }
  end
end
