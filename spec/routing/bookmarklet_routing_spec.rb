describe BookmarkletController do

  describe 'show' do
    it { has_named_route :bookmarklet, '/bookmarklet/show' }
    it { is_expected.to route(:get, '/bookmarklet/show').to action: 'show' }
  end

end
