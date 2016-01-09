describe PeopleController do

  describe 'autocomplete_usernames' do
    it { has_named_route :autocomplete_usernames, "/autocomplete_usernames" }
    it { has_named_route :autocomplete_usernames, 'foo', "/autocomplete_usernames/foo" }
    it { is_expected.to route(:get, '/autocomplete_usernames').to controller: 'people', action: 'autocomplete_usernames' }
    it { is_expected.to route(:get, '/autocomplete_usernames/foo').to controller: 'people', action: 'autocomplete_usernames', term: 'foo' }
  end

  describe 'find' do
    it { has_named_route :find_person, '/people/find' }
    it { is_expected.to route(:get, '/people/find').to action: 'find' }
  end

  describe 'index' do
    it { has_named_route :people, 'foo', 'bar', '/people/sorted-by/foo/order/bar' }
    it { is_expected.to route(:get, '/people/sorted-by/foo/order/bar').to(action: 'index', sorted_by: 'foo', order: 'bar') }
  end

  %w{ nemeses top_guessers }.each do |action|
    describe action do
      it { has_named_route "#{action}_people", "/people/#{action}" }
      it { is_expected.to route(:get, "/people/#{action}").to action: action }
    end
  end

  describe 'show' do
    it { has_named_route :person, 666, '/people/666' }
    it { is_expected.to route(:get, '/people/666').to action: 'show', id: '666' }
  end

  %w{ guesses map map_json }.each do |action|
    describe action do
      it { has_named_route "person_#{action}", 666, "/people/666/#{action}" }
      it { is_expected.to route(:get, "/people/666/#{action}").to action: action, id: '666' }
    end
  end

  describe 'comments' do
    it { has_named_route :person_comments, 666, 1, '/people/666/comments/page/1' }
    it { is_expected.to route(:get, '/people/666/comments/page/1').to action: 'comments', id: '666', page: '1' }
  end

end
