require 'spec_helper'

describe PeopleHelper do
  without_transactions

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

  describe '#to_four_places' do
    it 'returns the number, rounded to four places, as a string' do
      helper.to_4_places(1.11111).should == "1.1111"
    end
  end

  describe '#infinity_or' do
    it 'returns the number, rounded to four places, as a string' do
      helper.infinity_or(1.11111).should == "1.1111"
    end

    it 'returns HTML for infinity' do
      helper.infinity_or(Person::INFINITY).should == '&#8734;'
    end
    
  end

  describe '#thumbnail_with_alt' do
    it "renders a thumbnail with a link to the photo's page and alt text " +
      "(which can't be tested due to the lack of rspec support, discussed here http://www.ruby-forum.com/topic/188667)"
  end

  describe '#place' do
    it "renders the trophy's place " +
      "(which can't be tested due to the lack of rspec support, discussed here http://www.ruby-forum.com/topic/188667)"
  end

  describe '#star_and_alt' do
    describe 'for age' do
      expected = [
        [ nil => nil ],
        [ :bronze, 'Unfound for 1 year or more' ],
        [ :silver, 'Unfound for 2 years or more' ],
        [ :gold, 'Unfound for 3 years or more' ]
      ]
      expected.each do |star, period|
        it "returns the alt text '#{period}' given the star :#{star}" do
          guess = Object.new
          mock(guess).star_for_age { star }
          helper.star_and_alt(guess, :age).should == [ star, period ]
        end
      end
    end

    describe 'for speed' do
      expected = [
        [ :bronze, nil ],
        [ :silver, 'Guessed in less than a minute' ],
        [ :gold, 'Guessed in less than 10 seconds' ]
      ]
      expected.each do |star, period|
        it "returns the alt text '#{period}' given the star :#{star}" do
          guess = Object.new
          mock(guess).star_for_speed { star }
          helper.star_and_alt(guess, :speed).should == [ star, period ]
        end
      end
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

end
