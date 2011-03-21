require 'spec_helper'

describe PeopleController do
  without_transactions

  describe 'find' do
    it { should have_named_route :find_person, '/people/find' }
    it { should route(:get, '/people/find').to :controller => 'people', :action => 'find' }
  end

  describe 'list' do
    it { should have_named_route :people, 'foo', 'bar', '/people/sorted-by/foo/order/bar' }
    it { should route(:get, '/people/sorted-by/foo/order/bar').to(
      :controller => 'people', :action => 'index', :sorted_by => 'foo', :order => 'bar') }
  end

  %w{ nemeses top_guessers }.each do |action|
    describe action do
      it { should have_named_route "#{action}_people", "/people/#{action}" }
      it { should route(:get, "/people/#{action}").to :controller => 'people', :action => action }
    end
  end

  describe 'show' do
    it 'has a named route' do
      #noinspection RubyResolve
      show_person_path(666).should == '/people/show/666'
    end

    it { should route(:get, '/people/show/666').to :controller => 'people', :action => 'show', :id => '666' }

  end

  it 'routes to a plain action with an ID' do
    should route(:get, '/people/guesses/666').to :controller => 'people', :action => 'guesses', :id => '666'
  end

end
