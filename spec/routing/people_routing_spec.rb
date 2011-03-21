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

  describe 'nemeses' do
    it 'has a named route' do
      #noinspection RubyResolve
      nemeses_path.should == '/people/nemeses'
    end

    it { should route(:get, '/people/nemeses').to :controller => 'people', :action => 'nemeses' }

  end

  describe 'show' do
    it 'has a named route' do
      #noinspection RubyResolve
      show_person_path(666).should == '/people/show/666'
    end

    it { should route(:get, '/people/show/666').to :controller => 'people', :action => 'show', :id => '666' }

  end

  it 'routes to a plain action' do
    should route(:get, '/people/top_guessers').to :controller => 'people', :action => 'top_guessers'
  end

  it 'routes to a plain action with an ID' do
    should route(:get, '/people/guesses/666').to :controller => 'people', :action => 'guesses', :id => '666'
  end

end
