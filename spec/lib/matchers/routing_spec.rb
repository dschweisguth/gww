describe GWW::Matchers::Routing do
  include GWW::Matchers::Routing

  def no_params_path
    '/no_params'
  end

  def one_param_path(id)
    "/one_param/#{id}"
  end

  describe '#have_named_route' do
    it "blows up if created without an expected path" do
      lambda { have_named_route :no_params }.should raise_error ArgumentError
    end

    it "describes itself" do
      have_named_route(:no_params, '/no_params').description.should ==
        "have a route named no_params, where e.g. no_params_path == /no_params"
    end

    it "describes itself with a path with params" do
      have_named_route(:one_param, 666, '/one_param').description.should ==
        "have a route named one_param, where e.g. one_param_path(666) == /one_param"
    end

    it "asserts that the given name has a named route helper that returns the given path" do
      should have_named_route :no_params, '/no_params'
    end

    it "asserts that the given name has a named route helper that returns the given path" do
      should have_named_route :one_param, 666, '/one_param/666'
    end

    it "explains why should failed" do
      matcher = have_named_route :no_params, '/some_params'
      matcher.matches? nil
      matcher.failure_message_for_should.should ==
        "expected no_params_path to equal /some_params, but got /no_params"
    end

    it "explains why should_not failed" do
      matcher = have_named_route :no_params, '/no_params'
      matcher.matches? nil
      matcher.failure_message_for_should_not.should ==
        "expected no_params_path to not equal /no_params, but it did"
    end

  end

end
