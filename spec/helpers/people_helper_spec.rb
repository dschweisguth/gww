require 'spec_helper'

describe PeopleHelper do
  describe '#list_path' do
    it 'returns the URI to the list sorted by the given criterion' do
      list_path_should_return 'date-added', '+', 'username', '/people/list/sorted-by/username/order/+'
    end

    it 'reverses the sort order if the list is already sorted by the given criterion' do
      list_path_should_return 'username', '+', 'username', '/people/list/sorted-by/username/order/-'
    end

    it 'restores the sort order if the list is already reverse-sorted by the given criterion' do
      list_path_should_return 'username', '-', 'username', '/people/list/sorted-by/username/order/+'
    end

    def list_path_should_return(current_criterion, current_order, requested_criterion, expected_uri)
      params[:sorted_by] = current_criterion
      params[:order] = current_order
      helper.list_path(requested_criterion).should == expected_uri
    end

  end

  describe '#position' do
    before :all do
      @person = person_with 0
    end

    it "returns the appropriate prefix for '-most': '', if the person is first" do
      position_should_return [], ''
    end

    it "returns the appropriate prefix for '-most': '', if the person is tied for first" do
      position_should_return [0], ''
    end

    it "returns the appropriate prefix for '-most': 'second-', if the person is second" do
      position_should_return [1], 'second-'
    end

    it "returns the appropriate prefix for '-most': 'second-', if the person is tied for second" do
      position_should_return [1, 0], 'second-'
    end

    it "returns the appropriate prefix for '-most': 'third-', if the person is third" do
      position_should_return [2, 1], 'third-'
    end

    it "returns the appropriate prefix for '-most': 'third-', if the person is behind two others tied for first" do
      position_should_return [1, 1], 'third-'
    end

    it "returns the appropriate prefix for '-most': 'fourth-', if the person is fourth" do
      position_should_return [1, 1, 1], 'fourth-'
    end

    it "returns the appropriate prefix for '-most': 'fifth-', if the person is fifth" do
      position_should_return [1, 1, 1, 1], 'fifth-'
    end

    def position_should_return(higher_scores, expected)
      high_scorers = higher_scores.map { |score| person_with score }
      #noinspection RubyResolve
      high_scorers.push @person
      helper.position(high_scorers, @person).should == expected
    end

    def person_with(score)
      person = Person.new
      person[:score] = score
      person
    end

  end

  describe '#image_for_star' do
    expected = {
      :bronze => '/images/star-bronze.gif',
      :silver => '/images/star-silver.gif',
      :gold => '/images/star-gold.gif'
    }
    expected.keys.each do |star|
      it "returns the image URI #{expected[star]} given the star :#{star}" do
        helper.image_for_star(star).should == expected[star]
      end
    end
  end

end
