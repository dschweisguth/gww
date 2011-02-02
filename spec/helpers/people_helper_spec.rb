require 'spec_helper'

describe PeopleHelper do
  describe '#list_path' do
    it 'returns the URI to the list sorted by the given criterion' do
      list_path_should_return 'score', '+', 'username', '/people/list/sorted-by/username/order/+'
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
      person = Person.new

      high_scorers = higher_scores.map do |score|
        higher_scorer = Person.new
        higher_scorer[:score] = score
        higher_scorer
      end
      # Clone the person before setting their score to simulate the caller's
      # situation, where the people in the first argument have :score but the
      # second argument does not.
      person_with_score = person.clone
      person_with_score[:score] = 0
      high_scorers.push person_with_score

      helper.position(high_scorers, person).should == expected
    end

  end

  describe '#image_for_star' do
    expected = {
      :bronze => '/images/star-bronze.gif',
      :silver => '/images/star-silver.gif',
      :gold => '/images/star-gold.gif'
    }
    expected.each_pair do |star, uri|
      it "returns the image URI #{uri} given the star :#{star}" do
        helper.image_for_star(star).should == uri
      end
    end
  end

  describe '#alt_for_star_for_age' do
    expected = {
      :bronze => '1 year',
      :silver => '2 years',
      :gold => '3 years'
    }
    expected.each_pair do |star, period|
      it "returns the alt text 'Unfound for #{period} or more' given the star :#{star}" do
        helper.alt_for_star_for_age(star).should == "Unfound for #{period} or more"
      end
    end
  end

  describe '#alt_for_star_for_speed' do
    expected = {
      :bronze => nil,
      :silver => 'Guessed in less than a minute',
      :gold => 'Guessed in less than 10 seconds'
    }
    expected.each_pair do |star, period|
      it "returns the alt text '#{period}' given the star :#{star}" do
        helper.alt_for_star_for_speed(star).should == period
      end
    end
  end

end
