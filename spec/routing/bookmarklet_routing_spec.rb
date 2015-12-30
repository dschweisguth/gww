describe BookmarkletController do

  describe 'show' do
    it { is_expected.to have_named_route :bookmarklet, '/bookmarklet/show' }
    it { is_expected.to route(:get, '/bookmarklet/show').to action: 'show' }
  end

end
