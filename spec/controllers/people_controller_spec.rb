require 'spec_helper'

describe PeopleController do
  integrate_views
  without_transactions

  describe '#find' do
    it 'finds a person' do
      person = Person.make
      stub(Person).find_by_multiple_fields('username') { person }
      get :find, :person => { :username => 'username' }

      #noinspection RubyResolve
      response.should redirect_to person_path person

    end

    it 'punts back to the home page' do
      stub(Person).find_by_multiple_fields('xxx') { nil }
      get :find, :person => { :username => 'xxx' }
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
      response.should have_tag "a[href=#{people_path 'score', '-'}]", :text => 'Score'
      response.should have_tag "a[href=#{person_path person}]", :text => 'username'

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
      response.should have_tag "a[href=#{person_path guesser}]", "guesser_username"
      response.should have_tag "a[href=#{person_path poster}]", "poster_username"
      response.should have_tag 'td', '%.3f' % guesser[:bias].to_s

    end
  end

  describe '#top_guessers' do
    it 'renders the page' do
      report_day = Time.utc(2011, 1, 3)
      top_guessers = [
        (0 .. 6).map { |i| Period.starting_at report_day - i.days, 1.day },
          [ Period.new report_day.beginning_of_week - 1.day, report_day + 1.day ] +
            (0 .. 4).map { |i| Period.starting_at report_day.beginning_of_week - 1.day - (i + 1).weeks, 1.week },
          [ Period.new report_day.beginning_of_month, report_day + 1.day ] +
            (0 .. 11).map { |i| Period.starting_at report_day.beginning_of_month - (i + 1).months, 1.month },
          [ Period.new report_day.beginning_of_year, report_day + 1.day ]
      ]
      person = Person.make :id => 666
      guess = Guess.make :person => person, :guessed_at => report_day
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
      response.should have_tag "table" do
        with_tag "th", :text => title
        with_tag "tr" do
          with_tag "td.opening-number", :text => "1"
          with_tag "a[href=#{person_path guess.person}]", :text => 'username'
        end
      end
    end

  end

  describe '#old_show' do
    it "redirects to the new show" do
      get :old_show, :id => 666
      #noinspection RubyResolve
      response.should redirect_to person_path(666)
    end
  end
  
  describe '#show' do
    before do
      @person = Person.make :id => 1
      @person[:score] = 1 # for the high_scorers methods
      @person[:posts] = 1 # for the top_posters methods
      stub(Person).find(@person.id.to_s) { @person }
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
      response.should have_tag "a[href=#{person_map_path @person}]"
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
      #noinspection RubyResolve
      stub(Guess).find_all_by_person_id(@person.id, anything) { [] }
      stub(@person).favorite_posters { [] }

      stub_posts
      
      get :show, :id => @person.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag "a[href=#{person_map_path @person}]"

      response.should have_text /username has never made a correct guess/
      response.should_not have_text /username scored the most points in the last week/
      response.should_not have_text /username scored the most points in the last month/
      response.should have_text /username has correctly guessed 0 photos/
      response.should_not have_text /Of the photos that username has guessed,/
      response.should_not have_text /username is the nemesis of/

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
      #noinspection RubyResolve
      stub(Photo).find_all_by_person_id(@person.id, anything) { [] }
      stub(Photo).all { [] }
      #noinspection RubyResolve
      stub(Photo).find_all_by_person_id_and_game_status(@person.id, 'revealed') { [] }
      stub(@person).favorite_posters_of { [] }

      get :show, :id => @person.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag "a[href=#{person_map_path @person}]"

      renders_bits_for_user_who_has_guessed

      response.should have_text /username has never posted a photo to the group/
      response.should_not have_text /username posted the most photos in the last week/
      response.should_not have_text /username posted the most photos in the last month/
      response.should have_tag 'h2', :text => /username has posted 0 photos/
      response.should_not have_text /Of the photos that username has posted/
      response.should_not have_text /remains unfound/
      response.should_not have_text /was revealed/
      response.should_not have_text /username's nemesis is/

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

      #noinspection RubyResolve
      stub(Guess).find_all_by_person_id(@person.id, anything) \
        { [ Guess.make('all1'), Guess.make('all2') ] }

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

      most_commented = Photo.make 'most_commented'
      most_commented[:comment_count] = 1
      most_commented[:place] = 1
      stub(Photo).most_commented(@person) { most_commented }

      most_viewed = Photo.make 'most_viewed'
      most_viewed[:place] = 1
      stub(Photo).most_viewed(@person) { most_viewed }

      found1 = Guess.make 'found1'
      found1.photo.guesses << found1
      found2 = Guess.make 'found2'
      found2.photo.guesses << found2
      #noinspection RubyResolve
      stub(Photo).find_all_by_person_id(@person.id, anything) { [ found1.photo, found2.photo ] }

      stub(Photo).all { [ Photo.make 'unfound' ] }

      #noinspection RubyResolve
      stub(Photo).find_all_by_person_id_and_game_status(@person.id, 'revealed') \
        { [ Photo.make 'revealed' ] }

      favorite_poster_of = Person.make 'favorite_poster_of'
      favorite_poster_of[:bias] = 3.6
      stub(@person).favorite_posters_of { [ favorite_poster_of ] }

    end

    def renders_bits_for_user_who_has_guessed
      response.should have_text /username is in 1st place with a score of 2./
      response.should have_text /username scored the most points in the last week/
      response.should have_text /username scored the most points in the last month/
      response.should have_tag 'h2', :text => /username has correctly guessed 2 photos/
      response.should have_text /Of the photos that username has guessed,/
      response.should have_tag 'p', :text => /username is the nemesis of favorite_poster_username \(2.5\)/
    end

    def renders_bits_for_user_who_has_posted
      response.should have_text /username has posted 2 photos to the group, the most/
      response.should have_text /username posted the most photos in the last week/
      response.should have_text /username posted the most photos in the last month/
      response.should have_tag 'h2', :text => /username has posted 2 photos/
      response.should have_text /1 remains unfound/
      response.should have_text /1 was revealed/
      response.should have_tag 'p', :text => /username's nemesis is favorite_poster_of_username \(3.6\)/
    end

  end

  describe '#guesses' do
    it 'renders the page' do
      person = Person.make :id => 1
      stub(Person).find(person.id.to_s) { person }
      #noinspection RubyResolve
      stub(Guess).find_all_by_person_id(person.id.to_s, anything) { [ Guess.make :person => person ] }
      get :guesses, :id => person.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'h1', :text => '1 guess by username'
      response.should have_tag 'a', :text => 'guessed_photo_poster_username'

    end
  end

  describe '#posts' do
    it 'renders the page' do
      person = Person.make :id => 1
      stub(Person).find(person.id.to_s) { person }
      photo = Photo.make :person => person
      #noinspection RubyResolve
      stub(Photo).find_all_by_person_id(person.id.to_s, anything) { [ photo ] }
      get :posts, :id => person.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'h1', :text => '1 photo posted by username'
      response.should have_tag "a[href=#{person_path person}]"
      response.should have_tag "img[src=#{url_for_flickr_image photo, 't'}]"
      response.should have_tag 'td', :text => 'false'
      response.should have_tag 'td', :text => 'unfound'

    end
  end

  describe '#comments' do
    it 'renders the page' do
      person = Person.make :id => 1
      stub(Person).find(person.id.to_s) { person }

      #noinspection RubyResolve
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
      response.should have_tag 'h1', :text => '1 photo commented on by username'
      response.should have_tag "a[href=#{url_for_flickr_photo photo}]", :text => 'Flickr'
      response.should have_tag "a[href=#{photo_path photo}]", :text => 'GWW'
      response.should have_tag "a[href=#{person_path photo.person}]", :text => 'poster_username'

    end
  end

  describe '#map' do
    before do
      @person = Person.make :id => 1
      stub(Person).find(@person.id.to_s) { @person }
    end

    it "renders the page" do
      stub_mapped_counts 1, 1
      post = stub_post
      guessed_photo = stub_guessed_photo
      get :map, :id => @person.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'input[id=posts]'
      response.should have_tag 'label', :text => '1 mapped post (?, -)'
      response.should have_tag 'input[id=guesses]'
      response.should have_tag 'label', :text => '1 mapped guess (!)'
      response.should have_text /GWW\.config = \[\{"photo":\{.*?\}\},\{"photo":\{.*?\}\}\];/

      json = decode_json
      json.length.should == 2
      decoded_post_has_expected_attrs json[0], post
      decoded_guessed_photo_has_expected_attrs json[1], guessed_photo

    end

    it "shows only the guess count if there are no posts" do
      stub_mapped_counts 0, 1
      stub(Photo).all_mapped(@person.id.to_s) { [] }
      guessed_photo = stub_guessed_photo
      get :map, :id => @person.id

      #noinspection RubyResolve
      response.should be_success
      response.should_not have_tag 'input[id=posts]'
      response.should_not have_text /mapped post/
      response.should_not have_tag 'input[id=guesses]'
      response.should have_text /1 mapped guess/

      json = decode_json
      json.length.should == 1
      decoded_guessed_photo_has_expected_attrs json[0], guessed_photo

    end

    it "shows only the post count if there are no guesses" do
      stub_mapped_counts 1, 0
      post = stub_post
      stub(Guess).all_mapped(@person.id.to_s) { [] }
      get :map, :id => @person.id

      #noinspection RubyResolve
      response.should be_success
      response.should_not have_tag 'input[id=posts]'
      response.should have_text /1 mapped post/
      response.should_not have_tag 'input[id=guesses]'
      response.should_not have_text /mapped guess/

      json = decode_json
      json.length.should == 1
      decoded_post_has_expected_attrs json[0], post

    end

    def stub_mapped_counts(post_count, guess_count)
      stub(Photo).mapped_count(@person.id.to_s) { post_count }
      stub(Guess).mapped_count(@person.id.to_s) { guess_count }
    end

    def stub_post
      post = Photo.make :id => 14, :person => @person, :game_status => 'found'
      stub(Photo).all_mapped(@person.id.to_s) { [ post ] }
      post
    end

    def stub_guessed_photo
      guessed_photo = Photo.make :id => 15
      guess = Guess.make :photo => guessed_photo, :person => @person
      stub(Guess).all_mapped(@person.id.to_s) { [ guess ] }
      guessed_photo
    end

    def decode_json
      ActiveSupport::JSON.decode assigns[:json]
    end

    def decoded_post_has_expected_attrs(decoded_post, post)
      photo = decoded_post['photo']
      photo['id'].should == post.id
      photo['pin_color'].should == '0000FF'
      photo['symbol'].should == '?'
    end

    def decoded_guessed_photo_has_expected_attrs(decoded_guessed_photo, guessed_photo)
      photo = decoded_guessed_photo['photo']
      photo['id'].should == guessed_photo.id
      photo['pin_color'].should == '008000'
      photo['symbol'].should == '!'
    end

  end

  describe '.scaled_red' do
    it "starts at FCC0C0 (more or less FFBFBF)" do
      PeopleController.scaled_red(0, 1, 0).should == 'FCC0C0'
    end

    it "ends at E00000 (more or less DF0000)" do
      PeopleController.scaled_red(0, 1, 1).should == 'E00000'
    end

    it "handles a single point" do
      PeopleController.scaled_red(0, 0, 0).should == 'E00000'
    end

  end

  describe '.scaled_green' do
    it "starts at E0FCE0 (more or less DFFFDF)" do
      PeopleController.scaled_green(0, 1, 0).should == 'E0FCE0'
    end

    it "ends at 008000 (more or less 007F00)" do
      PeopleController.scaled_green(0, 1, 1).should == '008000'
    end

    it "handles a single point" do
      PeopleController.scaled_green(0, 0, 0).should == '008000'
    end

  end

  describe '.scaled_blue' do
    it "starts at E0E0FF (more or less DFDFFF)" do
      PeopleController.scaled_blue(0, 1, 0).should == 'E0E0FF'
    end

    it "ends at 0000FF" do
      PeopleController.scaled_blue(0, 1, 1).should == '0000FF'
    end

    it "handles a single point" do
      PeopleController.scaled_blue(0, 0, 0).should == '0000FF'
    end

  end

end
