require 'spec_helper'

describe PeopleController do
  render_views

  describe '#find' do
    it 'finds a person' do
      person = Person.make
      stub(Person).find_by_multiple_fields('username') { person }
      get :find, :username => 'username'

      #noinspection RubyResolve
      response.should redirect_to person_path person

    end

    it 'punts back to the home page' do
      stub(Person).find_by_multiple_fields('xxx') { nil }
      get :find, :username => 'xxx'
      response.should redirect_to root_path
      flash[:find_person_error].should == 'xxx'
    end

  end

  describe '#index' do
    it 'renders the page' do
      sorted_by_param = 'score'
      order_param = '+'

      person = Person.make :id => 666
      person[:guess_count] = 1
      person[:post_count] = 1
      person[:score_plus_posts] = 1
      person[:guesses_per_day] = 1.0
      person[:posts_per_day] = 1.0
      person[:posts_per_guess] = 1.0
      person[:guess_speed] = 1.0
      person[:be_guessed_speed] = 1.0
      person[:comments_to_guess] = 1.0
      person[:comments_per_post] = 1.0
      person[:comments_to_be_guessed] = 1.0
      person[:views_per_post] = 1.0
      stub(Person).all_sorted(sorted_by_param, order_param) { [ person ] }
      get :index, :sorted_by => sorted_by_param, :order => order_param

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'a', :href => people_path('score', '-'), :content => 'Score'
      response.should have_selector 'a', :href => person_path(person), :content => 'username'

    end
  end

  describe '#nemeses' do
    it "renders the page" do
      guesser = Person.make 'guesser', :id => 666
      poster = Person.make 'poster', :id => 777
      guesser[:poster] = poster
      guesser[:bias] = 2.5
      stub(Person).nemeses { [ guesser ] }
      get :nemeses

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'a', :href => person_path(guesser), :content => 'guesser_username'
      response.should have_selector 'a', :href => person_path(poster), :content => 'poster_username'
      response.should have_selector 'td', :content => '%.3f' % guesser[:bias]

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
      person = Person.make :id => 666
      guess = Guess.make :person => person, :commented_at => report_day
      (0 .. 3).each { |division| top_guessers[division][0].scores[1] = [ person ] }
      stub(Person).top_guessers { top_guessers }
      get :top_guessers

      #noinspection RubyResolve
      response.should be_success
      response_has_table "for Monday, January 03 so far ...", guess
      response_has_table "for the week of January 02 so far ...", guess
      response_has_table "for January 2011 so far ...", guess
      response_has_table "for 2011 so far ...", guess

    end

    def response_has_table(title, guess)
      response.should have_selector 'table' do |table|
        table.should have_selector 'th', :content => title
        table.should have_selector 'tr' do |tr|
          tr.should have_selector "td.opening-number", :content => "1"
          tr.should have_selector 'a', :href => person_path(guess.person), :content => 'username'
        end
      end
    end

  end

  describe '#show' do
    before do
      @person = Person.make :id => 1
      @person[:score] = 1 # for the high_scorers methods
      @person[:posts] = 1 # for the top_posters methods
      stub(Person).find(@person.id) { @person }
      stub(Person).standing { [ 1, false ] }
      stub(Person).posts_standing { [ 1, false ] }

      @now = Time.now
      stub(Time).now { @now }

    end

    it "renders the page" do
      stub_guesses
      stub_posts
      get :show, :id => @person.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'a', :href => person_map_path(@person)
      renders_bits_for_user_who_has_guessed
      renders_bits_for_user_who_has_posted

    end

    it "handles a person who has never guessed" do
      stub(Guess).mapped_count { 0 }
      stub(Person).high_scorers(@now, 7) { [] }
      stub(Person).high_scorers(@now, 30) { [] }
      stub(Guess).first_by(@person)
      stub(Guess).most_recent_by(@person)
      stub(Guess).oldest(@person)
      stub(Guess).fastest(@person)
      stub(Guess).longest_lasting(@person)
      stub(Guess).shortest_lasting(@person)
      stub(Guess).where.stub!.includes { [] }
      stub(@person).favorite_posters { [] }

      stub_posts
      
      get :show, :id => @person.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'a', :href => person_map_path(@person)

      response.should contain 'username has never made a correct guess'
      response.should_not contain 'username scored the most points in the last week'
      response.should_not contain 'username scored the most points in the last month'
      response.should contain 'username has correctly guessed 0 photos'
      response.should_not contain 'Of the photos that username has guessed,'
      response.should_not contain 'username is the nemesis of'

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
      stub(Photo).where(:person_id => @person).stub!.includes { [] }
      stub(Photo).where(is_a(String), @person) { [] }
      stub(Photo).find_all_by_person_id_and_game_status(@person, 'revealed') { [] }
      stub(@person).favorite_posters_of { [] }

      get :show, :id => @person.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'a', :href => person_map_path(@person)

      renders_bits_for_user_who_has_guessed

      response.should contain 'username has never posted a photo to the group'
      response.should_not contain 'username posted the most photos in the last week'
      response.should_not contain 'username posted the most photos in the last month'
      response.should have_selector 'h2', :content => 'username has posted 0 photos'
      response.should_not contain 'Of the photos that username has posted'
      response.should_not contain 'remains unfound'
      response.should_not contain 'was revealed'
      response.should_not contain "username's nemesis is"

    end

    def stub_guesses
      stub(Guess).mapped_count { 1 }

      stub(Person).high_scorers(@now, 7) { [ @person ] }
      stub(Person).high_scorers(@now, 30) { [ @person ] }

      first_guess = Guess.make 'first_guess'
      stub(Guess).first_by(@person) { first_guess }

      most_recent_guess = Guess.make 'most_recent_guess'
      stub(Guess).most_recent_by(@person) { most_recent_guess }

      oldest_guess = Guess.make 'oldest_guess'
      oldest_guess[:place] = 1
      stub(Guess).oldest(@person) { oldest_guess }

      fastest_guess = Guess.make 'fastest_guess'
      fastest_guess[:place] = 1
      stub(Guess).fastest(@person) { fastest_guess }

      longest_lasting_guess = Guess.make 'longest_lasting_guess'
      longest_lasting_guess[:place] = 1
      stub(Guess).longest_lasting(@person) { longest_lasting_guess }

      shortest_lasting_guess = Guess.make 'shortest_lasting_guess'
      shortest_lasting_guess[:place] = 1
      stub(Guess).shortest_lasting(@person) { shortest_lasting_guess }

      stub(Guess).find_with_associations(@person) { [ Guess.make('all1'), Guess.make('all2') ] }

      favorite_poster = Person.make 'favorite_poster'
      favorite_poster[:bias] = 2.5
      stub(@person).favorite_posters { [ favorite_poster ] }

    end

    def stub_posts
      stub(Photo).mapped_count { 1 }

      stub(Person).top_posters(@now, 7) { [ @person ] }
      stub(Person).top_posters(@now, 30) { [ @person ] }

      first_post = Photo.make 'first_post'
      stub(Photo).first_by(@person) { first_post }

      most_recent_post = Photo.make 'most_recent_post'
      stub(Photo).most_recent_by(@person) { most_recent_post }

      oldest_unfound = Photo.make 'oldest_unfound'
      oldest_unfound[:place] = 1
      stub(Photo).oldest_unfound(@person) { oldest_unfound }

      most_commented = Photo.make 'most_commented', :other_user_comments => 1
      most_commented[:place] = 1
      stub(Photo).most_commented(@person) { most_commented }

      most_viewed = Photo.make 'most_viewed'
      most_viewed[:place] = 1
      stub(Photo).most_viewed(@person) { most_viewed }

      found1 = Guess.make 'found1'
      found1.photo.guesses << found1
      found2 = Guess.make 'found2'
      found2.photo.guesses << found2
      stub(Photo).find_with_guesses(@person) { [ found1.photo, found2.photo ] }

      stub(Photo).where(is_a(String), @person) { [ Photo.make('unfound') ] }

      stub(Photo).find_all_by_person_id_and_game_status(@person, 'revealed') { [ Photo.make('revealed') ] }

      favorite_poster_of = Person.make 'favorite_poster_of'
      favorite_poster_of[:bias] = 3.6
      stub(@person).favorite_posters_of { [ favorite_poster_of ] }

    end

    def renders_bits_for_user_who_has_guessed
      response.should contain 'username is in 1st place with a score of 2.'
      response.should contain 'username scored the most points in the last week'
      response.should contain 'username scored the most points in the last month'
      response.should have_selector 'h2', :content => 'username has correctly guessed 2 photos'
      response.should contain 'Of the photos that username has guessed,'
      response.should have_selector 'a', :content => 'favorite_poster_username'
    end

    def renders_bits_for_user_who_has_posted
      response.should contain 'username has posted 2 photos to the group, the most'
      response.should contain 'username posted the most photos in the last week'
      response.should contain 'username posted the most photos in the last month'
      response.should have_selector 'h2', :content => 'username has posted 2 photos'
      response.should contain '1 remains unfound'
      response.should contain '1 was revealed'
      response.should have_selector 'a', :content => 'favorite_poster_of_username'
    end

  end

  describe '#guesses' do
    it 'renders the page' do
      person = Person.make :id => 1
      stub(Person).find(person.id) { person }
      stub(Guess).where.stub!.order.stub!.includes { [ Guess.make(:person => person) ] }
      get :guesses, :id => person.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'h1', :content => '1 guess by username'
      response.should have_tag 'a', :content => 'guessed_photo_poster_username'

    end
  end

  describe '#posts' do
    it 'renders the page' do
      person = Person.make :id => 1
      stub(Person).find(person.id) { person }
      photo = Photo.make :person => person
      stub(Photo).where.stub!.order.stub!.includes { [ photo ] }
      get :posts, :id => person.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'h1', :content => '1 photo posted by username'
      response.should have_tag 'a', :href => person_path(person)
      response.should have_tag 'img', :src => url_for_flickr_image(photo, 't')
      response.should have_tag 'td', :content => 'false'
      response.should have_tag 'td', :content => 'unfound'

    end
  end

  describe '#comments' do
    it 'renders the page' do
      person = Person.make :id => 1
      stub(Person).find(person.id) { person }

      photo = Photo.make
      stub(Comment).find_by_sql { [ photo ] }

      paginated_photos = [ photo ]
      # Mock methods from will_paginate's version of Array
      stub(paginated_photos).offset { 0 }
      stub(paginated_photos).total_pages { 1 }
      stub(Photo).paginate { paginated_photos }

      get :comments, :id => person.id, :page => "2"

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'h1', :content => '1 photo commented on by username'
      response.should have_selector 'a', :href => url_for_flickr_photo_in_pool(photo), :content => 'Flickr'
      response.should have_selector 'a', :href => photo_path(photo), :content => 'GWW'
      response.should have_selector 'a', :href => person_path(photo.person), :content => 'poster_username'

    end
  end

  describe '#map' do
    it "renders the page" do
      person = Person.make :id => 1
      stub(Person).find(person.id) { person }
      stub(Photo).mapped_count(person.id) { 1 }
      stub(Guess).mapped_count(person.id) { 1 }
      json = { 'property' => 'value' }
      stub(controller).map_photos(person.id) { json }
      get :map, :id => person.id

      assigns[:json].should == json.to_json

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'input', :id => 'posts'
      response.should have_selector 'label', :content => '1 mapped post (?, -)'
      response.should have_selector 'input', :id => 'guesses'
      response.should have_selector 'label', :content => '1 mapped guess (!)'
      response.should contain /GWW\.config = #{Regexp.escape assigns[:json]};/

    end
  end

  describe '#map_json' do
    it "renders the page" do
      json = { 'property' => 'value' }
      stub(controller).map_photos(1) { json }
      get :map_json, :id => 1

      #noinspection RubyResolve
      response.should be_success
      response.body.should == json.to_json

    end
  end

  describe '#map_photos' do
    before do
      @person = Person.make :id => 1
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

    it "copies an inferred geocode to the stated one" do
      post = Photo.make :id => 14, :person_id => @person.id, :inferred_latitude => 37, :inferred_longitude => -122
      stub(Photo).posted_or_guessed_by_and_mapped(@person.id, @initial_bounds, @default_max_photos + 1) { [ post ] }
      stub(Photo).oldest { Photo.make :dateadded => 1.day.ago }
      controller.map_photos(@person.id).should == {
        :partial => false,
        :bounds => @initial_bounds,
        :photos => [
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

    it "returns a guess" do
      photo = Photo.make :id => 15, :person_id => 2, :latitude => 37, :longitude => -122
      stub(Photo).posted_or_guessed_by_and_mapped(@person.id, @initial_bounds, @default_max_photos + 1) { [ photo ] }
      stub(Photo).oldest { Photo.make :dateadded => 1.day.ago }
      controller.map_photos(@person.id).should == {
        :partial => false,
        :bounds => @initial_bounds,
        :photos => [
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
      returns_post Bounds.new(1, 3, 2, 4), 'unfound', 'FFFF00', '?'
    end

    def returns_post(bounds, game_status, color, symbol)
      post = Photo.make :id => 14, :person_id => @person.id, :latitude => 37, :longitude => -122, :game_status => game_status
      stub(Photo).posted_or_guessed_by_and_mapped(@person.id, bounds, @default_max_photos + 1) { [ post ] }
      stub(Photo).oldest { Photo.make :dateadded => 1.day.ago }
      controller.map_photos(@person.id).should == {
        :partial => false,
        :bounds => bounds,
        :photos => [
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

    it "returns no more than a maximum number of photos" do
      stub(controller).max_map_photos { 1 }
      post = Photo.make :id => 14, :person_id => @person.id, :latitude => 37, :longitude => -122
      oldest_photo = Photo.make :dateadded => 1.day.ago
      stub(Photo).posted_or_guessed_by_and_mapped(@person.id, @initial_bounds, 2) { [ post, oldest_photo ] }
      stub(Photo).oldest { oldest_photo }
      controller.map_photos(@person.id).should == {
        :partial => true,
        :bounds => @initial_bounds,
        :photos => [
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
        :partial => false,
        :bounds => @initial_bounds,
        :photos => []
      }
    end

  end

end
