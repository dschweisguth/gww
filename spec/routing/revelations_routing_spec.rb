describe RevelationsController do

  describe 'longest' do
    it { has_named_route :longest_revelations, '/revelations/longest' }
    it { is_expected.to route(:get, '/revelations/longest').to action: 'longest' }
  end

end
