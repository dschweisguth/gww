describe PhotosController do
  describe 'index' do
    it { has_named_route? :photos, 'foo', 'bar', 1, '/photos/sorted-by/foo/order/bar/page/1' }
    it { does route(:get, '/photos/sorted-by/foo/order/bar/page/1').to(action: 'index', sorted_by: 'foo', order: 'bar', page: '1') }
  end

  %w(map map_json unfound_data).each do |action|
    describe action do
      it { has_named_route? "#{action}_photos", "/photos/#{action}" }
      it { does route(:get, "/photos/#{action}").to action: action }
    end
  end

  describe 'map_popup' do
    it { has_named_route? :map_popup_photo, 666, '/photos/666/map_popup' }
    it { does route(:get, '/photos/666/map_popup').to action: 'map_popup', id: '666' }
  end

  describe 'search' do
    it { has_named_route? :search_photos, '/photos/search' }
    it { has_named_route? :search_photos, 'game-status/unfound,unconfirmed', '/photos/search/game-status/unfound,unconfirmed' }
    it { does route(:get, '/photos/search').to action: 'search' }
    it { does route(:get, '/photos/search/foo/bar').to(action: 'search', segments: 'foo/bar') }
  end

  describe 'search_data' do
    it { has_named_route? :search_photos_data, 'page/1', '/photos/search_data/page/1' }
    it { does route(:get, '/photos/search_data/page/1').to action: 'search_data', segments: 'page/1' }
    it { does route(:get, '/photos/search_data/foo/bar/page/1').to action: 'search_data', segments: 'foo/bar/page/1' }
  end

  describe '#autocomplete_usernames' do
    it { has_named_route? :autocomplete_photos_usernames, "/photos/autocomplete_usernames" }
    it { has_named_route? :autocomplete_photos_usernames, 'foo', "/photos/autocomplete_usernames/foo" }
    it { does route(:get, '/photos/autocomplete_usernames').to controller: 'photos', action: 'autocomplete_usernames' }
    it { does route(:get, '/photos/autocomplete_usernames/foo').to controller: 'photos', action: 'autocomplete_usernames', terms: 'foo' }
  end

  describe 'show' do
    it { has_named_route? :photo, 666, '/photos/666' }
    it { does route(:get, '/photos/666').to action: 'show', id: '666' }
  end

end
