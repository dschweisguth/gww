require 'spec_helper'

describe Admin::RootController do
  without_transactions

  # TODO Dave move to support
  def have_named_route(name, *args)
    HaveNamedRoute.new(self, name, *args)
  end

  class HaveNamedRoute
    def initialize(context, name, *args)
      @context = context
      @name = name
      @path = "#{name}_path"
      @args = args
      if ! args.last
        raise ArgumentError, 'The last argument must be the expected uri'
      end
      @expected_uri = args.pop
    end

    def description
      "have a route named #{@name}, where e.g. #{example_call} == #{@expected_uri}"
    end

    def matches?(subject)
      @actual_uri = @context.send("#{@name}_path", *@args)
      @actual_uri == @expected_uri
    end

    def failure_message_for_should
      "expected #{example_call} to equal #{@expected_uri}, but got #{@actual_uri}"
    end

    def failure_message_for_should_not
      "expected #{example_call} to not equal #{@expected_uri}, but it did"
    end

    def example_call
      # TODO Dave remove parens if not needed
      "#{@name}_path(#{@args.map(&:to_s).join(', ')})"
    end

  end

  describe 'index' do
    it { should have_named_route :admin_root, '/admin' }
    it { should route(:get, '/admin').to :controller => 'admin/root', :action => 'index' }
  end

  it 'routes to a plain action' do
    should route(:get, '/admin/bookmarklet').to :controller => 'admin/root', :action => 'bookmarklet'
  end

end
