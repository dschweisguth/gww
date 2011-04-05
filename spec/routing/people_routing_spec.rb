require 'spec_helper'

describe PeopleController do

  describe 'find' do
    it { should have_named_route :find_person, '/people/find' }
    it { should route(:get, '/people/find').to :controller => 'people', :action => 'find' }
  end

  describe 'index' do
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
    it { should have_named_route :person, 666, '/people/666' }
    it { should route(:get, '/people/666').to :controller => 'people', :action => 'show', :id => '666' }
  end

  %w{ guesses posts map }.each do |action|
    describe action do
      it { should have_named_route "person_#{action}", 666, "/people/666/#{action}" }
      it { should route(:get, "/people/666/#{action}").to :controller => 'people', :action => action, :id => '666' }
    end
  end

  describe 'comments' do
    it { should have_named_route :person_comments, 666, 1, '/people/666/comments/page/1' }
    it { should route(:get, '/people/666/comments/page/1').to :controller => 'people', :action => 'comments', :id => '666', :page => '1' }
  end

end
