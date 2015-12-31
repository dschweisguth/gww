describe PeopleHelper do

  describe '#other_people_path' do
    it 'returns the URI to the list sorted by the given criterion' do
      other_people_path_returns 'score', '+', 'username', '/people/sorted-by/username/order/+'
    end

    it 'reverses the sort order if the list is already sorted by the given criterion' do
      other_people_path_returns 'username', '+', 'username', '/people/sorted-by/username/order/-'
    end

    it 'restores the sort order if the list is already reverse-sorted by the given criterion' do
      other_people_path_returns 'username', '-', 'username', '/people/sorted-by/username/order/+'
    end

    def other_people_path_returns(current_criterion, current_order, requested_criterion, expected_uri)
      controller.params[:sorted_by] = current_criterion
      controller.params[:order] = current_order
      expect(helper.other_people_path(requested_criterion)).to eq(expected_uri)
    end

  end

  describe '#to_four_places' do
    it 'returns the number, rounded to four places, as a string' do
      expect(helper.to_4_places(1.11111)).to eq('1.1111')
    end
  end

  describe '#infinity_or' do
    it 'returns the number, rounded to four places, as a string' do
      expect(helper.infinity_or(1.11111)).to eq('1.1111')
    end

    it 'returns HTML for infinity' do
      expect(helper.infinity_or(Float::MAX)).to eq('&#8734;')
    end
    
  end

  STARS = [ nil, :bronze, :silver, :gold ]

  describe '#star_and_alt' do
    describe 'for age' do
      STARS.each do |star|
        alt = PeopleHelper::ALT[:age][star]
        it "returns the alt '#{alt}' given the star :#{star}" do
          guess = double star_for_age: star
          expect(helper.star_and_alt(guess, :age)).to eq([ star, alt ])
        end
      end
    end

    describe 'for speed' do
      STARS.each do |star|
        alt = PeopleHelper::ALT[:speed][star]
        it "returns the alt '#{alt}' given the star :#{star}" do
          guess = double star_for_speed: star
          expect(helper.star_and_alt(guess, :speed)).to eq([ star, alt ])
        end
      end
    end

    describe 'for comments' do
      STARS.each do |star|
        alt = PeopleHelper::ALT[:comments][star]
        it "returns the alt '#{alt}' given the star :#{star}" do
          photo = double star_for_comments: star
          expect(helper.star_and_alt(photo, :comments)).to eq([ star, alt ])
        end
      end
    end

    describe 'for views' do
      STARS.each do |star|
        alt = PeopleHelper::ALT[:views][star]
        it "returns the alt '#{alt}' given the star :#{star}" do
          photo = double star_for_views: star
          expect(helper.star_and_alt(photo, :views)).to eq([ star, alt ])
        end
      end
    end

    describe 'for faves' do
      STARS.each do |star|
        alt = PeopleHelper::ALT[:faves][star]
        it "returns the alt '#{alt}' given the star :#{star}" do
          photo = double star_for_faves: star
          expect(helper.star_and_alt(photo, :faves)).to eq([ star, alt ])
        end
      end
    end

  end

  describe '#position' do
    it "returns the appropriate prefix for '-most': '', if the person is first" do
      position_returns [], ''
    end

    it "returns the appropriate prefix for '-most': '', if the person is tied for first" do
      position_returns [0], ''
    end

    it "returns the appropriate prefix for '-most': 'second-', if the person is second" do
      position_returns [1], 'second-'
    end

    it "returns the appropriate prefix for '-most': 'second-', if the person is tied for second" do
      position_returns [1, 0], 'second-'
    end

    it "returns the appropriate prefix for '-most': 'third-', if the person is third" do
      position_returns [2, 1], 'third-'
    end

    it "returns the appropriate prefix for '-most': 'third-', if the person is behind two others tied for first" do
      position_returns [1, 1], 'third-'
    end

    it "returns the appropriate prefix for '-most': 'fourth-', if the person is fourth" do
      position_returns [1, 1, 1], 'fourth-'
    end

    it "returns the appropriate prefix for '-most': 'fifth-', if the person is fifth" do
      position_returns [1, 1, 1, 1], 'fifth-'
    end

    def position_returns(higher_scores, expected)
      person = Person.new

      high_scorers = higher_scores.map do |score|
        higher_scorer = Person.new
        higher_scorer.score = score
        higher_scorer
      end
      # Clone the person before setting their score to simulate the caller's
      # situation, where the people in the first argument have :score but the
      # second argument does not.
      person_with_score = person.clone
      person_with_score.score = 0
      high_scorers.push person_with_score

      expect(helper.position(high_scorers, person, :score)).to eq(expected)
    end

  end

  describe '#image_for_star' do
    expected = {
      bronze: 'star-bronze.gif',
      silver: 'star-silver.gif',
      gold: 'star-gold.gif'
    }
    expected.each_pair do |star, file_name|
      it "returns the image file name #{file_name} given the star :#{star}" do
        expect(helper.image_for_star(star)).to eq(file_name)
      end
    end
  end

end
