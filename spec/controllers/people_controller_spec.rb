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
      response.should have_selector 'td', :content => '%.3f' % guesser[:bias].to_s

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
      stub(Person).find(@person.id.to_s) { @person }
      stub(Person).standing { [ 1, false ] }
      stub(Person).posts_standing { [ 1, false ] }

      @now = Time.now
      stub(Time).now { @now }

    end

    it "renders the page" do
      stub_guesses
      stub_posts
      get :show, :id => @person.id.to_s

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
      
      get :show, :id => @person.id.to_s

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
      stub(Photo).where.stub!.includes { [] }
      stub(Photo).all { [] }
      stub(Photo).find_all_by_person_id_and_game_status(@person.id, 'revealed') { [] }
      stub(@person).favorite_posters_of { [] }

      get :show, :id => @person.id.to_s

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

      stub(Guess).where.stub!.includes { [ Guess.make('all1'), Guess.make('all2') ] }

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
      stub(Photo).where.stub!.includes { [ found1.photo, found2.photo ] }

      stub(Photo).all { [ Photo.make('unfound') ] }

      stub(Photo).find_all_by_person_id_and_game_status(@person.id, 'revealed') { [ Photo.make('revealed') ] }

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
      stub(Person).find(person.id.to_s) { person }
      stub(Guess).find_all_by_person_id(person.id.to_s, anything) { [ Guess.make(:person => person) ] }
      get :guesses, :id => person.id.to_s

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'h1', :content => '1 guess by username'
      response.should have_tag 'a', :content => 'guessed_photo_poster_username'

    end
  end

  describe '#posts' do
    it 'renders the page' do
      person = Person.make :id => 1
      stub(Person).find(person.id.to_s) { person }
      photo = Photo.make :person => person
      stub(Photo).find_all_by_person_id(person.id.to_s, anything) { [ photo ] }
      get :posts, :id => person.id.to_s

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
      stub(Person).find(person.id.to_s) { person }

      photo = Photo.make
      stub(Comment).find_by_sql { [ photo ] }

      paginated_photos = [ photo ]
      # Mock methods from will_paginate's version of Array
      stub(paginated_photos).offset { 0 }
      stub(paginated_photos).total_pages { 1 }
      stub(Photo).paginate { paginated_photos }

      get :comments, :id => person.id.to_s, :page => "2"

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'h1', :content => '1 photo commented on by username'
      response.should have_selector 'a', :href => url_for_flickr_photo(photo), :content => 'Flickr'
      response.should have_selector 'a', :href => photo_path(photo), :content => 'GWW'
      response.should have_selector 'a', :href => person_path(photo.person), :content => 'poster_username'

    end
  end

  describe '#map' do
    before do
      @person = Person.make :id => 1
      stub(Person).find(@person.id.to_s) { @person }
    end

    it "renders the page" do
      stub_mapped_counts 1, 1
      post = stub_unfound
      guessed_photo = stub_guessed_photo
      get :map, :id => @person.id.to_s

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'input', :id => 'posts'
      response.should have_selector 'label', :content => '1 mapped post (?, -)'
      response.should have_selector 'input', :id => 'guesses'
      response.should have_selector 'label', :content => '1 mapped guess (!)'
      response.should contain /GWW\.config = \[\{"photo":\{.*?\}\},\{"photo":\{.*?\}\}\];/

      json = decode_json
      json.length.should == 2
      decoded_photo_looks_unfound_or_unconfirmed json[0], post
      decoded_photo_looks_guessed json[1], guessed_photo

    end

    it "shows only the guess count if there are no posts" do
      stub_mapped_counts 0, 1
      stub(Photo).all_mapped(@person.id.to_s) { [] }
      guessed_photo = stub_guessed_photo
      get :map, :id => @person.id.to_s

      #noinspection RubyResolve
      response.should be_success
      response.should_not have_selector 'input', :id => 'posts'
      response.should_not contain 'mapped post'
      response.should_not have_selector 'input', :id => 'guesses'
      response.should contain '1 mapped guess'

      json = decode_json
      json.length.should == 1
      decoded_photo_looks_guessed json[0], guessed_photo

    end

    it "shows only the post count if there are no guesses" do
      stub_mapped_counts 1, 0
      post = stub_unfound
      stub(Guess).all_mapped(@person.id.to_s) { [] }
      get :map, :id => @person.id.to_s

      #noinspection RubyResolve
      response.should be_success
      response.should_not have_selector 'input', :id => 'posts'
      response.should contain '1 mapped post'
      response.should_not have_selector 'input', :id => 'guesses'
      response.should_not contain 'mapped guess'

      json = decode_json
      json.length.should == 1
      decoded_photo_looks_unfound_or_unconfirmed json[0], post

    end

    it "displays an unconfirmed like an unfound" do
      stub_mapped_counts 1, 1
      post = Photo.make :id => 14, :person => @person, :game_status => 'unconfirmed'
      stub(Photo).all_mapped(@person.id.to_s) { [ post ] }
      get :map, :id => @person.id.to_s

      json = decode_json
      json.length.should == 1
      decoded_photo_looks_unfound_or_unconfirmed json[0], post

    end

    it "displays a found differently" do
      stub_mapped_counts 1, 1
      post = Photo.make :id => 14, :person => @person, :game_status => 'found'
      stub(Photo).all_mapped(@person.id.to_s) { [ post ] }
      get :map, :id => @person.id.to_s

      json = decode_json
      json.length.should == 1
      photo = json[0]['photo']
      photo['color'].should == '0000FC'
      photo['symbol'].should == '?'

    end

    it "displays a revealed photo differently" do
      stub_mapped_counts 1, 1
      post = Photo.make :id => 14, :person => @person, :game_status => 'revealed'
      stub(Photo).all_mapped(@person.id.to_s) { [ post ] }
      get :map, :id => @person.id.to_s

      json = decode_json
      json.length.should == 1
      photo = json[0]['photo']
      photo['color'].should == 'E00000'
      photo['symbol'].should == '-'

    end

    def stub_mapped_counts(post_count, guess_count)
      stub(Photo).mapped_count(@person.id.to_s) { post_count }
      stub(Guess).mapped_count(@person.id.to_s) { guess_count }
    end

    def stub_unfound
      post = Photo.make :id => 14, :person => @person
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

    def decoded_photo_looks_unfound_or_unconfirmed(decoded_post, post)
      photo = decoded_post['photo']
      photo['id'].should == post.id
      photo['color'].should == 'FFFF00'
      photo['symbol'].should == '?'
    end

    def decoded_photo_looks_guessed(decoded_guessed_photo, guessed_photo)
      photo = decoded_guessed_photo['photo']
      photo['id'].should == guessed_photo.id
      photo['color'].should == '008000'
      photo['symbol'].should == '!'
    end

  end

end
