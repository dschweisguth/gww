describe PeopleController do
  render_views

  describe '#find' do
    it 'finds a person' do
      person = build_stubbed :person
      stub(Person).find_by_multiple_fields('username') { person }
      get :find, username: 'username'

      response.should redirect_to person_path person

    end

    it 'punts back to the home page' do
      stub(Person).find_by_multiple_fields('xxx') { nil }
      get :find, username: 'xxx'
      response.should redirect_to root_path
      flash[:find_person_error].should == 'xxx'
    end

  end

  describe '#index' do
    it 'renders the page' do
      sorted_by_param = 'score'
      order_param = '+'

      person = build_stubbed :person
      person.guess_count = 1
      person.post_count = 1
      person.score_plus_posts = 1
      person.guesses_per_day = 1.0
      person.posts_per_day = 1.0
      person.posts_per_guess = 1.0
      person.guess_speed = 1.0
      person.be_guessed_speed = 1.0
      person.comments_to_guess = 1.0
      person.comments_per_post = 1.0
      person.comments_to_be_guessed = 1.0
      person.views_per_post = 1.0
      person.faves_per_post = 1.0
      stub(Person).all_sorted(sorted_by_param, order_param) { [ person ] }
      get :index, sorted_by: sorted_by_param, order: order_param

      response.should be_success
      response.body.should have_link 'Score', href: people_path('score', '-')
      response.body.should have_link person.username, href: person_path(person)

    end
  end

  describe '#nemeses' do
    it "renders the page" do
      guesser = build_stubbed :person, bias: 2.5
      poster = build_stubbed :person
      guesser.poster = poster
      stub(Person).nemeses { [ guesser ] }
      get :nemeses

      response.should be_success
      response.body.should have_link guesser.username, href: person_path(guesser)
      response.body.should have_link poster.username, href: person_path(poster)
      response.body.should have_css 'td', text: '%.3f' % guesser.bias

    end
  end

  describe '#top_guessers' do
    it 'renders the page' do
      report_day = Time.utc(2011, 1, 3)
      top_guessers = [
        (0 .. 6).map { |i| Period.starting_at report_day - i.days, 1.day },
          [ Period.new(report_day.beginning_of_week - 1.day, report_day + 1.day) ] +
            (0 .. 4).map { |i| Period.starting_at report_day.beginning_of_week - 1.day - (i + 1).weeks, 1.week },
          [ Period.new(report_day.beginning_of_month, report_day + 1.day) ] +
            (0 .. 11).map { |i| Period.starting_at(report_day.beginning_of_month - (i + 1).months, 1.month) },
          [ Period.new(report_day.beginning_of_year, report_day + 1.day) ]
      ]
      person = build_stubbed :person
      guess = build_stubbed :guess, person: person, commented_at: report_day
      (0 .. 3).each { |division| top_guessers[division][0].scores[1] = [ person ] }
      stub(Person).top_guessers { top_guessers }
      get :top_guessers

      response.should be_success
      response_has_table "for Monday, January 03 so far ...", guess
      response_has_table "for the week of January 02 so far ...", guess
      response_has_table "for January 2011 so far ...", guess
      response_has_table "for 2011 so far ...", guess

    end

    def response_has_table(title, guess)
      # Restricting the class avoids the enclosing container table
      tables = top_node.all('table[class=dark]').select { |table| table.has_selector? 'th', text: title }
      tables.count.should == 1
      table = tables.first
      table.should have_css 'td.opening-number', text: '1'
      table.should have_link 'username', href: person_path(guess.person)
    end

  end

  describe '#show' do
    let(:person) { build_stubbed :person }

    before do
      person.score = 1 # for the high_scorers methods
      person.post_count = 1 # for the top_posters methods
      stub(Person).find(person.id) { person }
      stub(person).score_standing { [ 1, false ] }
      stub(person).posts_standing { [ 1, false ] }

      @now = Time.now
      stub(Time).now { @now }

    end

    it "renders the page" do
      stub_guesses
      stub_posts
      get :show, id: person.id

      response.should be_success
      response.body.should have_css %Q(a[href="#{person_map_path(person)}"]) # the link text is HTML-encoded
      renders_bits_for_user_who_has_guessed
      renders_bits_for_user_who_has_posted

    end

    it "handles a person who has never guessed" do
      stub_no_guesses
      stub_posts
      
      get :show, id: person.id

      response.should be_success
      response.body.should have_css %Q([href="#{person_map_path(person)}"])

      response.body.should include "#{person.username} has never made a correct guess"
      response.body.should_not include "#{person.username} scored the most points in the last week"
      response.body.should_not include "#{person.username} scored the most points in the last month"
      response.body.should include "#{person.username} has correctly guessed 0 photos"
      response.body.should_not include "Of the photos that #{person.username} has guessed,"
      response.body.should_not include "#{person.username} is the nemesis of"

      renders_bits_for_user_who_has_posted

    end

    it "handles a person who has never posted" do
      stub_guesses

      stub(person).mapped_photo_count { 0 }
      stub(Person).top_posters(@now, 7) { [] }
      stub(Person).top_posters(@now, 30) { [] }
      stub(person).first_photo
      stub(person).most_recent_photo
      stub(person).oldest_unfound_photo
      stub(person).most_commented_photo
      stub(person).most_viewed_photo
      stub(person).most_faved_photo
      stub(person).photos_with_associations { [] }
      stub(person).favoring_guessers { [] }
      stub(person).unfound_photos { [] }
      stub(person).revealed_photos { [] }

      get :show, id: person.id

      response.should be_success
      response.body.should have_css %Q([href="#{person_map_path(person)}"])

      renders_bits_for_user_who_has_guessed

      response.body.should include "#{person.username} has never posted a photo to the group"
      response.body.should_not include "#{person.username} posted the most photos in the last week"
      response.body.should_not include "#{person.username} posted the most photos in the last month"
      response.body.should have_css 'h2', text: "#{person.username} has posted 0 photos"
      response.body.should_not include "Of the photos that #{person.username} has posted"
      response.body.should_not include 'remains unfound'
      response.body.should_not include 'was revealed'
      response.body.should_not include "#{person.username}'s nemesis is"

    end

    context "when highlighting a post" do
      let(:photo) { build_stubbed :photo }

      before do
        stub_no_guesses
        stub_posts
        stub(person).photos_with_associations { [] }
        stub(person).revealed_photos { [] }
      end

      it "does not highlight a guessed post which is mapped and has no obsolete tags" do
        stub_guessed_post
        stub(photo).mapped_or_automapped? { true }
        get :show, id: person.id

        top_node.should_not have_css('.photo-links a.unmapped')
        top_node.should_not have_css('.photo-links a.needs-attention')

      end

      it "does not highlight a revealed post which is mapped and has no obsolete tags" do
        stub_revealed_post
        stub(photo).mapped_or_automapped? { true }
        get :show, id: person.id

        top_node.should_not have_css('.photo-links a.unmapped')
        top_node.should_not have_css('.photo-links a.needs-attention')

      end

      it "highlights a guessed post which is not mapped" do
        stub_guessed_post
        stub(photo).mapped_or_automapped? { false }
        get :show, id: person.id

        top_node.should have_css('.photo-links a.unmapped')

      end

      it "highlights a revealed post which is not mapped" do
        stub_revealed_post
        stub(photo).mapped_or_automapped? { false }
        get :show, id: person.id

        top_node.should have_css('.photo-links a.unmapped')

      end

      it "highlights a guessed post with an obsolete tag" do
        stub_guessed_post
        stub(photo).has_obsolete_tags? { true }
        get :show, id: person.id

        top_node.should have_css('.photo-links a.needs-attention')

      end

      it "highlights a revealed post with an obsolete tag" do
        stub_revealed_post
        stub(photo).has_obsolete_tags? { true }
        get :show, id: person.id

        top_node.should have_css('.photo-links a.needs-attention')

      end

      def stub_guessed_post
        found1 = build_stubbed :guess, photo: photo, person: build_stubbed(:person)
        stub(photo).guesses { [found1] }
        # noinspection RubyArgCount
        stub(person).photos_with_associations { [ photo ] }
      end

      def stub_revealed_post
        # noinspection RubyArgCount
        stub(person).revealed_photos { [photo] }
      end

    end

    # noinspection RubyArgCount
    def stub_no_guesses
      stub(person).mapped_guess_count { 0 }
      stub(Person).high_scorers(@now, 7) { [] }
      stub(Person).high_scorers(@now, 30) { [] }
      stub(person).first_guess
      stub(person).most_recent_guess
      stub(person).oldest_guess
      stub(person).fastest_guess
      stub(person).guess_of_longest_lasting_post
      stub(person).guess_of_shortest_lasting_post
      stub(person).guesses_with_associations { [] }
      stub(person).favorite_posters { [] }
    end

    # noinspection RubyArgCount
    def stub_guesses
      stub(person).mapped_guess_count { 1 }

      stub(Person).high_scorers(@now, 7) { [ person ] }
      stub(Person).high_scorers(@now, 30) { [ person ] }

      stub(person).first_guess { build_stubbed :guess }
      stub(person).most_recent_guess { build_stubbed :guess }
      stub(person).oldest_guess { build_stubbed :guess, place: 1 }
      stub(person).fastest_guess { build_stubbed :guess, place: 1 }

      stub(person).guess_of_longest_lasting_post { build_stubbed :guess, place: 1 }
      stub(person).guess_of_shortest_lasting_post { build_stubbed :guess, place: 1 }

      # It's important to the test that these guesses are of photos by different people with different IDs
      stub(person).guesses_with_associations { [build_stubbed(:guess), build_stubbed(:guess)] }

      @favorite_poster = build_stubbed :person, bias: 2.5
      stub(person).favorite_posters { [ @favorite_poster ] }

    end

    # noinspection RubyArgCount
    def stub_posts
      stub(person).mapped_photo_count { 1 }

      stub(Person).top_posters(@now, 7) { [ person ] }
      stub(Person).top_posters(@now, 30) { [ person ] }

      first_post = build_stubbed :photo
      stub(person).first_photo { first_post }

      most_recent_post = build_stubbed :photo
      stub(person).most_recent_photo { most_recent_post }

      stub(person).oldest_unfound_photo { build_stubbed :photo, place: 1 }
      stub(person).most_commented_photo { build_stubbed :photo, place: 1 }
      stub(person).most_viewed_photo { build_stubbed :photo, place: 1 }
      stub(person).most_faved_photo { build_stubbed :photo, place: 1 }

      found1 = build_stubbed :guess
      stub(found1.photo).guesses { [found1] }
      found2 = build_stubbed :guess
      stub(found2.photo).guesses { [found2] }
      stub(person).photos_with_associations { [ found1.photo, found2.photo ] }

      @favoring_guesser = build_stubbed :person, bias: 3.6
      stub(person).favoring_guessers { [ @favoring_guesser ] }

      stub(person).unfound_photos { [ build_stubbed(:photo) ] }
      stub(person).revealed_photos { [ build_stubbed(:photo) ] }

    end

    def renders_bits_for_user_who_has_guessed
      response.body.should include "#{person.username} is in 1st place with a score of 2."
      response.body.should include "#{person.username} scored the most points in the last week"
      response.body.should include "#{person.username} scored the most points in the last month"
      response.body.should have_css 'h2', text: "#{person.username} has correctly guessed 2 photos"
      response.body.should include "Of the photos that #{person.username} has guessed,"
      response.body.should have_link @favorite_poster.username
    end

    def renders_bits_for_user_who_has_posted
      response.body.should include "#{person.username} has posted 2 photos to the group, the most"
      response.body.should include "#{person.username} posted the most photos in the last week"
      response.body.should include "#{person.username} posted the most photos in the last month"
      response.body.should have_css 'h2', text: "#{person.username} has posted 2 photos"
      response.body.should include '1 remains unfound'
      response.body.should include '1 was revealed'
      response.body.should have_link @favoring_guesser.username
    end

  end

  describe '#guesses' do
    it 'renders the page' do
      guesser = build_stubbed :person
      stub(Person).find(guesser.id) { guesser }
      poster = build_stubbed :person
      photo = build_stubbed :photo, person: poster
      stub(guesser).guesses_with_associations_ordered_by_comments { [ build_stubbed(:guess, person: guesser, photo: photo) ] }
      get :guesses, id: guesser.id

      response.should be_success
      response.body.should have_css 'h1', text: '1 guess by username'
      response.body.should have_link poster.username

    end
  end

  describe '#comments' do
    it 'renders the page' do
      person = build_stubbed :person
      stub(Person).find(person.id) { person }

      photo = build_stubbed :photo
      paginated_photos = [ photo ]
      # Stub methods from will_paginate's version of Array
      stub(paginated_photos).offset { 0 }
      stub(paginated_photos).total_pages { 1 }
      stub(paginated_photos).total_entries { 1 }
      stub(person).paginated_commented_photos('1') { paginated_photos }

      get :comments, id: person.id, page: '1'

      response.should be_success
      response.body.should have_css 'h1', text: "1 photo commented on by #{person.username}"
      response.body.should have_link 'Flickr', href: url_for_flickr_photo_in_pool(photo)
      response.body.should have_link 'GWW', href: photo_path(photo)
      response.body.should have_link photo.person.username, href: person_path(photo.person)

    end
  end

  describe '#map' do
    it "renders the page" do
      person = build_stubbed :person
      stub(Person).find(person.id) { person }
      stub(person).mapped_photo_count { 1 }
      stub(person).mapped_guess_count { 1 }
      json = { 'property' => 'value' }
      stub(Photo).for_person_for_map(person.id, PeopleController::INITIAL_MAP_BOUNDS, PeopleController::MAX_MAP_PHOTOS) { json }
      get :map, id: person.id

      assigns[:json].should == json.to_json

      response.should be_success
      response.body.should have_css 'input[id=posts]'
      response.body.should have_css 'label', text: '1 mapped post (?, -)'
      response.body.should have_css 'input[id=guesses]'
      response.body.should have_css 'label', text: '1 mapped guess (!)'
      response.body.should =~ /GWW\.config = #{Regexp.escape assigns[:json]};/

    end
  end

  describe '#map_json' do
    it "renders the page" do
      json = { 'property' => 'value' }
      stub(Photo).for_person_for_map(1, PeopleController::INITIAL_MAP_BOUNDS, PeopleController::MAX_MAP_PHOTOS) { json }
      get :map_json, id: 1

      response.should be_success
      response.body.should == json.to_json

    end

    it "supports arbitrary bounds" do
      stub(Photo).for_person_for_map(1, Bounds.new(0, 1, 10, 11), PeopleController::MAX_MAP_PHOTOS) { { 'property' => 'value' } }
      get :map_json, id: 1, sw: '0,10', ne: '1,11'
    end

  end

end
