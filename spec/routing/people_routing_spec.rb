require 'spec_helper'

describe PeopleController do
  without_transactions

  describe 'list' do
    it 'has a named route' do
      #noinspection RubyResolve
      list_people_path('foo', 'bar').should == '/people/list/sorted-by/foo/order/bar'
    end

    it { should route(:get, '/people/list/sorted-by/foo/order/bar').to(
      :controller => 'people', :action => 'list', :sorted_by => 'foo', :order => 'bar') }

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
