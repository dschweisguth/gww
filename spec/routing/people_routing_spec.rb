describe PeopleController do
  describe 'autocompletions' do
    it { has_named_route? :autocompletions, "/autocompletions" }
    it { has_named_route? :autocompletions, 'foo', "/autocompletions/foo" }
    it { does route(:get, '/autocompletions').to controller: 'people', action: 'autocompletions' }
    it { does route(:get, '/autocompletions/foo').to controller: 'people', action: 'autocompletions', term: 'foo' }
  end

  describe 'find' do
    it { has_named_route? :find_person, '/people/find' }
    it { does route(:get, '/people/find').to action: 'find' }
  end

  describe 'index' do
    it { has_named_route? :people, 'foo', 'bar', '/people/sorted-by/foo/order/bar' }
    it { does route(:get, '/people/sorted-by/foo/order/bar').to(action: 'index', sorted_by: 'foo', order: 'bar') }
  end

  %w(nemeses top_guessers).each do |action|
    describe action do
      it { has_named_route? "#{action}_people", "/people/#{action}" }
      it { does route(:get, "/people/#{action}").to action: action }
    end
  end

  describe 'show' do
    it { has_named_route? :person, 666, '/people/666' }
    it { does route(:get, '/people/666').to action: 'show', id: '666' }
  end

  %w(guesses map map_json).each do |action|
    describe action do
      it { has_named_route? "person_#{action}", 666, "/people/666/#{action}" }
      it { does route(:get, "/people/666/#{action}").to action: action, id: '666' }
    end
  end

  describe 'comments' do
    it { has_named_route? :person_comments, 666, 1, '/people/666/comments/page/1' }
    it { does route(:get, '/people/666/comments/page/1').to action: 'comments', id: '666', page: '1' }
  end

end
