describe PeopleController do
  render_views

  describe '#find' do
    it 'finds a person' do
      person = build :person, id: 1
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

      person = build :person, id: 666
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
      guesser = build :person, id: 666
      poster = build :person, id: 777
      guesser.poster = poster
      guesser.bias = 2.5
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
      person = build :person, id: 666
      guess = build :guess, person: person, commented_at: report_day
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
    before do
      @person = build :person, id: 1
      @person.score = 1 # for the high_scorers methods
      @person.post_count = 1 # for the top_posters methods
      stub(Person).find(@person.id) { @person }
      stub(@person).standing { [ 1, false ] }
      stub(@person).posts_standing { [ 1, false ] }

      @now = Time.now
      stub(Time).now { @now }

    end

    it "renders the page" do
      stub_guesses
      stub_posts
      get :show, id: @person.id

      response.should be_success
      response.body.should have_css %Q(a[href="#{person_map_path(@person)}"]) # the link text is HTML-encoded
      renders_bits_for_user_who_has_guessed
      renders_bits_for_user_who_has_posted

    end

    it "handles a person who has never guessed" do
      stub_no_guesses
      stub_posts
      
      get :show, id: @person.id

      response.should be_success
      response.body.should have_css %Q([href="#{person_map_path(@person)}"])

      response.body.should include "#{@person.username} has never made a correct guess"
      response.body.should_not include "#{@person.username} scored the most points in the last week"
      response.body.should_not include "#{@person.username} scored the most points in the last month"
      response.body.should include "#{@person.username} has correctly guessed 0 photos"
      response.body.should_not include "Of the photos that #{@person.username} has guessed,"
      response.body.should_not include "#{@person.username} is the nemesis of"

      renders_bits_for_user_who_has_posted

    end

    it "handles a person who has never posted" do
      stub_guesses

      stub(Photo).mapped_count { 0 }
      stub(Person).top_posters(@now, 7) { [] }
      stub(Person).top_posters(@now, 30) { [] }
      stub(Photo).first_by(@person)
      stub(Photo).most_recent_by(@person)
      stub(Photo).oldest_unfound(@person)
      stub(Photo).most_commented(@person)
      stub(Photo).most_viewed(@person)
      stub(Photo).most_faved(@person)
      stub(Photo).where(person_id: @person).stub!.includes.stub!.includes { [] } # TODO Dave which one is this?
      stub(@person).unfound_photos { [] }
      stub(Photo).where(person_id: @person, game_status: 'revealed').stub!.includes(:tags) { [] }
      stub(@person).favoring_guessers { [] }

      get :show, id: @person.id

      response.should be_success
      response.body.should have_css %Q([href="#{person_map_path(@person)}"])

      renders_bits_for_user_who_has_guessed

      response.body.should include "#{@person.username} has never posted a photo to the group"
      response.body.should_not include "#{@person.username} posted the most photos in the last week"
      response.body.should_not include "#{@person.username} posted the most photos in the last month"
      response.body.should have_css 'h2', text: "#{@person.username} has posted 0 photos"
      response.body.should_not include "Of the photos that #{@person.username} has posted"
      response.body.should_not include 'remains unfound'
      response.body.should_not include 'was revealed'
      response.body.should_not include "#{@person.username}'s nemesis is"

    end

    context "when highlighting a post" do
      let(:photo) { build :photo, id: 1 }

      before do
        stub_no_guesses
        stub_posts
        stub(Photo).find_with_guesses(@person) { [] }
        stub(Photo).where(person_id: @person, game_status: 'revealed').stub!.includes(:tags) { [] }
      end

      it "does not highlight a guessed post which is mapped and has no obsolete tags" do
        stub_guessed_post
        stub(photo).mapped_or_automapped? { true }
        get :show, id: @person.id

        top_node.should_not have_css('.photo-links a.unmapped')
        top_node.should_not have_css('.photo-links a.needs-attention')

      end

      it "does not highlight a revealed post which is mapped and has no obsolete tags" do
        stub_revealed_post
        stub(photo).mapped_or_automapped? { true }
        get :show, id: @person.id

        top_node.should_not have_css('.photo-links a.unmapped')
        top_node.should_not have_css('.photo-links a.needs-attention')

      end

      it "highlights a guessed post which is not mapped" do
        stub_guessed_post
        stub(photo).mapped_or_automapped? { false }
        get :show, id: @person.id

        top_node.should have_css('.photo-links a.unmapped')

      end

      it "highlights a revealed post which is not mapped" do
        stub_revealed_post
        stub(photo).mapped_or_automapped? { false }
        get :show, id: @person.id

        top_node.should have_css('.photo-links a.unmapped')

      end

      it "highlights a guessed post with an obsolete tag" do
        stub_guessed_post
        stub(photo).has_obsolete_tags? { true }
        get :show, id: @person.id

        top_node.should have_css('.photo-links a.needs-attention')

      end

      it "highlights a revealed post with an obsolete tag" do
        stub_revealed_post
        stub(photo).has_obsolete_tags? { true }
        get :show, id: @person.id

        top_node.should have_css('.photo-links a.needs-attention')

      end

      def stub_guessed_post
        found1 = build :guess, photo: photo, person: build(:person, id: 2)
        photo.guesses << found1
        # noinspection RubyArgCount
        stub(Photo).find_with_guesses(@person) { [ photo ] }
      end

      def stub_revealed_post
        # noinspection RubyArgCount
        stub(Photo).where(person_id: @person, game_status: 'revealed').stub!.includes(:tags) { [photo] }
      end

    end

    # noinspection RubyArgCount
    def stub_no_guesses
      stub(Guess).mapped_count { 0 }
      stub(Person).high_scorers(@now, 7) { [] }
      stub(Person).high_scorers(@now, 30) { [] }
      stub(Guess).first_by(@person)
      stub(Guess).most_recent_by(@person)
      stub(Guess).oldest(@person)
      stub(Guess).fastest(@person)
      stub(Guess).longest_lasting(@person)
      stub(Guess).shortest_lasting(@person)
      stub(@person).favorite_posters { [] }
    end

    # noinspection RubyArgCount
    def stub_guesses
      stub(Guess).mapped_count { 1 }

      stub(Person).high_scorers(@now, 7) { [ @person ] }
      stub(Person).high_scorers(@now, 30) { [ @person ] }

      first_guess = build :guess
      stub(Guess).first_by(@person) { first_guess }

      most_recent_guess = build :guess
      stub(Guess).most_recent_by(@person) { most_recent_guess }

      oldest_guess = build :guess
      oldest_guess.place = 1
      stub(Guess).oldest(@person) { oldest_guess }

      fastest_guess = build :guess
      fastest_guess.place = 1
      stub(Guess).fastest(@person) { fastest_guess }

      longest_lasting_guess = build :guess
      longest_lasting_guess.place = 1
      stub(Guess).longest_lasting(@person) { longest_lasting_guess }

      shortest_lasting_guess = build :guess
      shortest_lasting_guess.place = 1
      stub(Guess).shortest_lasting(@person) { shortest_lasting_guess }

      # Give the posters different IDs so that they're considered different people, we have a list of guesses from
      # more than one poster and code that handles that is tested
      stub(Guess).find_with_associations(@person) { [build(:guess, id: 1), build(:guess, id: 2)] }

      @favorite_poster = build :person, id: 3
      @favorite_poster.bias = 2.5
      stub(@person).favorite_posters { [ @favorite_poster ] }

    end

    # noinspection RubyArgCount
    def stub_posts
      stub(Photo).mapped_count { 1 }

      stub(Person).top_posters(@now, 7) { [ @person ] }
      stub(Person).top_posters(@now, 30) { [ @person ] }

      first_post = build :photo, id: 21
      stub(Photo).first_by(@person) { first_post }

      most_recent_post = build :photo, id: 22
      stub(Photo).most_recent_by(@person) { most_recent_post }

      oldest_unfound = build :photo, id: 23
      oldest_unfound.place = 1
      stub(Photo).oldest_unfound(@person) { oldest_unfound }

      most_commented = build :photo, id: 24
      most_commented.place = 1
      stub(Photo).most_commented(@person) { most_commented }

      most_viewed = build :photo, id: 25
      most_viewed.place = 1
      stub(Photo).most_viewed(@person) { most_viewed }

      most_faved = build :photo, id: 26
      most_faved.place = 1
      stub(Photo).most_faved(@person) { most_faved }

      found1 = build :guess
      found1.photo.guesses << found1
      found2 = build :guess
      found2.photo.guesses << found2
      stub(Photo).find_with_guesses(@person) { [ found1.photo, found2.photo ] }

      stub(@person).unfound_photos { [ build(:photo, id: 27) ] }

      stub(Photo).where(person_id: @person, game_status: 'revealed').stub!.includes(:tags) { [ build(:photo, id: 28) ] }

      @favoring_guesser = build :person, id: 4
      @favoring_guesser.bias = 3.6
      stub(@person).favoring_guessers { [ @favoring_guesser ] }

    end

    def renders_bits_for_user_who_has_guessed
      response.body.should include "#{@person.username} is in 1st place with a score of 2."
      response.body.should include "#{@person.username} scored the most points in the last week"
      response.body.should include "#{@person.username} scored the most points in the last month"
      response.body.should have_css 'h2', text: "#{@person.username} has correctly guessed 2 photos"
      response.body.should include "Of the photos that #{@person.username} has guessed,"
      response.body.should have_link @favorite_poster.username
    end

    def renders_bits_for_user_who_has_posted
      response.body.should include "#{@person.username} has posted 2 photos to the group, the most"
      response.body.should include "#{@person.username} posted the most photos in the last week"
      response.body.should include "#{@person.username} posted the most photos in the last month"
      response.body.should have_css 'h2', text: "#{@person.username} has posted 2 photos"
      response.body.should include '1 remains unfound'
      response.body.should include '1 was revealed'
      response.body.should have_link @favoring_guesser.username
    end

  end

  describe '#guesses' do
    it 'renders the page' do
      guesser = build :person, id: 1
      stub(Person).find(guesser.id) { guesser }
      poster = build :person, id: 2
      photo = build :photo, id: 1, person: poster
      stub(Guess).where.stub!.order.stub!.includes { [ build(:guess, person: guesser, photo: photo) ] }
      get :guesses, id: guesser.id

      response.should be_success
      response.body.should have_css 'h1', text: '1 guess by username'
      response.body.should have_link poster.username

    end
  end

  describe '#comments' do
    it 'renders the page' do
      person = build :person, id: 1
      stub(Person).find(person.id) { person }

      photo = build :photo, id: 1
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
      person = build :person, id: 1
      stub(Person).find(person.id) { person }
      stub(Photo).mapped_count(person.id) { 1 }
      stub(Guess).mapped_count(person.id) { 1 }
      json = { 'property' => 'value' }
      stub(controller).map_photos(person.id) { json }
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
      stub(controller).map_photos(1) { json }
      get :map_json, id: 1

      response.should be_success
      response.body.should == json.to_json

    end
  end

  describe '#map_photos' do
    before do
      @person = build :person, id: 1
      stub(Person).find(@person.id) { @person }
      @initial_bounds = PeopleController::INITIAL_MAP_BOUNDS
      @default_max_photos = controller.max_map_photos
    end

    it "returns a post" do
      returns_post @initial_bounds, 'unfound', 'FFFF00', '?'
    end

    it "configures an unconfirmed post like an unfound" do
      returns_post @initial_bounds, 'unconfirmed', 'FFFF00', '?'
    end

    it "configures a found differently" do
      returns_post @initial_bounds, 'found', '0000FC', '?'
    end

    it "configures a revealed post differently" do
      returns_post @initial_bounds, 'revealed', 'E00000', '-'
    end

    # noinspection RubyArgCount
    def returns_post(bounds, game_status, color, symbol)
      post = build :photo, id: 14, person_id: @person.id, latitude: 37, longitude: -122, game_status: game_status
      stub(Photo).posted_or_guessed_by_and_mapped(@person.id, bounds, @default_max_photos + 1) { [ post ] }
      stub(Photo).oldest { build :photo, dateadded: 1.day.ago }
      controller.map_photos(@person.id).should == {
        partial: false,
        bounds: bounds,
        photos: [
          {
            'id' => post.id,
            'latitude' => post.latitude,
            'longitude' => post.longitude,
            'color' => color,
            'symbol' => symbol
          }
        ]
      }
    end

    it "copies an inferred geocode to the stated one" do
      post = build :photo, id: 14, person_id: @person.id, inferred_latitude: 37, inferred_longitude: -122
      stub(Photo).posted_or_guessed_by_and_mapped(@person.id, @initial_bounds, @default_max_photos + 1) { [ post ] }
      stub(Photo).oldest { build :photo, dateadded: 1.day.ago }
      controller.map_photos(@person.id).should == {
        partial: false,
        bounds: @initial_bounds,
        photos: [
          {
            'id' => post.id,
            'latitude' => post.inferred_latitude,
            'longitude' => post.inferred_longitude,
            'color' => 'FFFF00',
            'symbol' => '?'
          }
        ]
      }
    end

    it "moves a younger post so that it doesn't completely overlap an older post with an identical location" do
      post1 = build :photo, id: 1, latitude: 37, longitude: -122, dateadded: 1.day.ago
      post2 = build :photo, id: 2, latitude: 37, longitude: -122
      stub(Photo).posted_or_guessed_by_and_mapped(@person.id, @initial_bounds, @default_max_photos + 1) { [ post2, post1 ] }
      stub(Photo).oldest { post1 }
      photos = controller.map_photos(@person.id)[:photos]
      photos[0]['latitude'].should be_within(0.000001).of 36.999991
      photos[0]['longitude'].should be_within(0.000001).of -122.000037
      photos[1]['latitude'].should == 37
      photos[1]['longitude'].should == -122
    end

    it "returns a guess" do
      photo = build :photo, id: 15, person_id: 2, latitude: 37, longitude: -122
      stub(Photo).posted_or_guessed_by_and_mapped(@person.id, @initial_bounds, @default_max_photos + 1) { [ photo ] }
      stub(Photo).oldest { build :photo, dateadded: 1.day.ago }
      controller.map_photos(@person.id).should == {
        partial: false,
        bounds: @initial_bounds,
        photos: [
          {
            'id' => photo.id,
            'latitude' => photo.latitude,
            'longitude' => photo.longitude,
            'color' => '008000',
            'symbol' => '!'
          }
        ]
      }
    end

    it "echos non-default bounds" do
      controller.params[:sw] = '1,2'
      controller.params[:ne] = '3,4'
      bounds = Bounds.new 1, 3, 2, 4
      stub(Photo).posted_or_guessed_by_and_mapped(@person.id, bounds, @default_max_photos + 1) { [] }
      stub(Photo).oldest { nil }
      controller.map_photos(@person.id)[:bounds].should == bounds
    end

    it "returns no more than a maximum number of photos" do
      stub(controller).max_map_photos { 1 }
      post = build :photo, id: 14, person_id: @person.id, latitude: 37, longitude: -122
      oldest_photo = build :photo, dateadded: 1.day.ago
      stub(Photo).posted_or_guessed_by_and_mapped(@person.id, @initial_bounds, 2) { [ post, oldest_photo ] }
      stub(Photo).oldest { oldest_photo }
      controller.map_photos(@person.id).should == {
        partial: true,
        bounds: @initial_bounds,
        photos: [
          {
            'id' => post.id,
            'latitude' => post.latitude,
            'longitude' => post.longitude,
            'color' => 'FFFF00',
            'symbol' => '?'
          }
        ]
      }
    end

    it "handles no photos" do
      stub(Photo).posted_or_guessed_by_and_mapped(@person.id, @initial_bounds, @default_max_photos + 1) { [] }
      stub(Photo).oldest { nil }
      controller.map_photos(@person.id).should == {
        partial: false,
        bounds: @initial_bounds,
        photos: []
      }
    end

  end

end
