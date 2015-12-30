describe RevelationsController do

  describe 'longest' do
    it { is_expected.to have_named_route :longest_revelations, '/revelations/longest' }
    it { is_expected.to route(:get, '/revelations/longest').to action: 'longest' }
  end

end
