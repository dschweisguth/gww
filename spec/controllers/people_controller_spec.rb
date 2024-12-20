require 'will_paginate/array'

describe PeopleController do
  describe '#find' do
    it "finds a person" do
      person = build_stubbed :people_person
      allow(PeoplePerson).to receive(:find_by_multiple_fields).with('username').and_return(person)
      get :find, username: 'username'

      expect(response).to redirect_to person_path person

    end

    it "punts back to the home page" do
      allow(PeoplePerson).to receive(:find_by_multiple_fields).with('xxx').and_return(nil)
      get :find, username: 'xxx'
      expect(response).to redirect_to root_path
      expect(flash[:find_person_error]).to eq('xxx')
    end

  end

  describe '#index' do
    it "renders the page" do
      sorted_by_param = 'score'
      order_param = '+'

      person = build_stubbed :people_index_person
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
      allow(PeopleIndexPerson).to receive(:all_sorted).with(sorted_by_param, order_param).and_return([person])
      get :index, sorted_by: sorted_by_param, order: order_param

      expect(response).to be_success
      expect(response.body).to have_link 'Score', href: people_path('score', '-')
      expect(response.body).to have_link person.username, href: person_path(person)

    end
  end

  describe '#nemeses' do
    it "renders the page" do
      guesser = build_stubbed :people_person, bias: 2.5
      poster = build_stubbed :people_person
      guesser.poster = poster
      allow(PeoplePerson).to receive(:nemeses).and_return([guesser])
      get :nemeses

      expect(response).to be_success
      expect(response.body).to have_link guesser.username, href: person_path(guesser)
      expect(response.body).to have_link poster.username, href: person_path(poster)
      expect(response.body).to have_css 'td', text: '%.3f' % guesser.bias

    end
  end

  describe '#top_guessers' do
    it "renders the page" do
      report_day = Time.utc(2011, 1, 3)
      top_guessers = [
        (0..6).map { |i| Period.starting_at report_day - i.days, 1.day },
        [Period.new(report_day.beginning_of_week - 1.day, report_day + 1.day)] +
          (0..4).map { |i| Period.starting_at report_day.beginning_of_week - 1.day - (i + 1).weeks, 1.week },
        [Period.new(report_day.beginning_of_month, report_day + 1.day)] +
          (0..11).map { |i| Period.starting_at(report_day.beginning_of_month - (i + 1).months, 1.month) },
        [Period.new(report_day.beginning_of_year, report_day + 1.day)]
      ]
      person = build_stubbed :people_person
      guess = build_stubbed :people_guess, person: person, commented_at: report_day
      (0..3).each { |division| top_guessers[division][0].scores[1] = [person] }
      allow(PeoplePerson).to receive(:top_guessers).and_return(top_guessers)
      get :top_guessers

      expect(response).to be_success
      response_has_table "for Monday, January 03 so far ...", guess
      response_has_table "for the week of January 02 so far ...", guess
      response_has_table "for January 2011 so far ...", guess
      response_has_table "for 2011 so far ...", guess

    end

    def response_has_table(title, guess)
      # Restricting the class avoids the enclosing container table
      tables = top_node.all('table[class=dark]').select { |table| table.has_selector? 'th', text: title }
      expect(tables.count).to eq(1)
      table = tables.first
      expect(table).to have_css 'td.opening-number', text: '1'
      expect(table).to have_link 'username', href: person_path(guess.person)
    end

  end

  describe '#show' do
    let(:person) { build_stubbed :people_show_person, high_score: 1, top_post_count: 1 }
    let(:now) { Time.now }
    let(:favorite_poster) { build_stubbed :people_show_person, bias: 2.5 }
    let(:favoring_guesser) { build_stubbed :people_show_person, bias: 3.6 }

    before do
      allow(PeopleShowPerson).to receive(:find).with(person.id).and_return(person)
      allow(person).to receive(:score_standing).and_return([1, false])
      allow(person).to receive(:posts_standing).and_return([1, false])

      allow(Time).to receive(:now).and_return(now)

    end

    it "renders the page" do
      stub_guesses
      stub_posts
      get :show, id: person.id

      expect(response).to be_success
      expect(response.body).to have_css 'h1', text: person.username_and_realname
      expect(response.body).to have_css %Q(a[href="#{person_map_path(person)}"]) # the link text is HTML-encoded
      renders_bits_for_user_who_has_guessed
      renders_bits_for_user_who_has_posted

    end

    it "handles a person who has never guessed" do
      stub_no_guesses
      stub_posts

      get :show, id: person.id

      expect(response).to be_success
      expect(response.body).to have_css %Q([href="#{person_map_path(person)}"])

      expect(response.body).to include "#{person.username} has never made a correct guess"
      expect(response.body).not_to include "#{person.username} scored the most points in the last week"
      expect(response.body).not_to include "#{person.username} scored the most points in the last month"
      expect(response.body).to include "#{person.username} has correctly guessed 0 photos"
      expect(response.body).not_to include "Of the photos that #{person.username} has guessed,"
      expect(response.body).not_to include "#{person.username} is the nemesis of"

      renders_bits_for_user_who_has_posted

    end

    it "handles a person who has never posted" do
      stub_guesses

      allow(person).to receive(:mapped_photo_count).and_return(0)
      allow(PeopleShowPerson).to receive(:top_posters).with(now, 7).and_return([])
      allow(PeopleShowPerson).to receive(:top_posters).with(now, 30).and_return([])
      allow(person).to receive(:first_photo)
      allow(person).to receive(:most_recent_photo)
      allow(person).to receive(:oldest_unfound_photo)
      allow(person).to receive(:most_commented_photo)
      allow(person).to receive(:most_viewed_photo)
      allow(person).to receive(:most_faved_photo)
      allow(person).to receive(:photos_with_associations).and_return([])
      allow(person).to receive(:favoring_guessers).and_return([])
      allow(person).to receive(:unfound_photos).and_return([])
      allow(person).to receive(:revealed_photos).and_return([])

      get :show, id: person.id

      expect(response).to be_success
      expect(response.body).to have_css %Q([href="#{person_map_path(person)}"])

      renders_bits_for_user_who_has_guessed

      expect(response.body).to include "#{person.username} has never posted a photo to the group"
      expect(response.body).not_to include "#{person.username} posted the most photos in the last week"
      expect(response.body).not_to include "#{person.username} posted the most photos in the last month"
      expect(response.body).to have_css 'h2', text: "#{person.username} has posted 0 photos"
      expect(response.body).not_to include "Of the photos that #{person.username} has posted"
      expect(response.body).not_to include 'remains unfound'
      expect(response.body).not_to include 'was revealed'
      expect(response.body).not_to include "#{person.username}'s nemesis is"

    end

    context "when highlighting a post" do
      let(:photo) { build_stubbed :people_show_photo }

      before do
        stub_no_guesses
        stub_posts
        allow(person).to receive(:photos_with_associations).and_return([])
        allow(person).to receive(:revealed_photos).and_return([])
      end

      it "does not highlight a guessed post which is mapped and has no obsolete tags" do
        stub_guessed_post
        allow(photo).to receive(:mapped_or_automapped?).and_return(true)
        get :show, id: person.id

        expect(top_node).not_to have_css('.photo-links a.unmapped')
        expect(top_node).not_to have_css('.photo-links a.needs-attention')

      end

      it "does not highlight a revealed post which is mapped and has no obsolete tags" do
        stub_revealed_post
        allow(photo).to receive(:mapped_or_automapped?).and_return(true)
        get :show, id: person.id

        expect(top_node).not_to have_css('.photo-links a.unmapped')
        expect(top_node).not_to have_css('.photo-links a.needs-attention')

      end

      it "highlights a guessed post which is not mapped" do
        stub_guessed_post
        allow(photo).to receive(:mapped_or_automapped?).and_return(false)
        get :show, id: person.id

        expect(top_node).to have_css('.photo-links a.unmapped')

      end

      it "highlights a revealed post which is not mapped" do
        stub_revealed_post
        allow(photo).to receive(:mapped_or_automapped?).and_return(false)
        get :show, id: person.id

        expect(top_node).to have_css('.photo-links a.unmapped')

      end

      it "highlights a guessed post with an obsolete tag" do
        stub_guessed_post
        allow(photo).to receive(:obsolete_tags?).and_return(true)
        get :show, id: person.id

        expect(top_node).to have_css('.photo-links a.needs-attention')

      end

      it "highlights a revealed post with an obsolete tag" do
        stub_revealed_post
        allow(photo).to receive(:obsolete_tags?).and_return(true)
        get :show, id: person.id

        expect(top_node).to have_css('.photo-links a.needs-attention')

      end

      def stub_guessed_post
        found1 = build_stubbed :people_show_guess, photo: photo, person: build_stubbed(:people_show_person)
        allow(photo).to receive(:guesses).and_return([found1])
        allow(person).to receive(:photos_with_associations).and_return([photo])
      end

      def stub_revealed_post
        allow(person).to receive(:revealed_photos).and_return([photo])
      end

    end

    def stub_no_guesses
      allow(person).to receive(:mapped_guess_count).and_return(0)
      allow(PeopleShowPerson).to receive(:high_scorers).with(now, 7).and_return([])
      allow(PeopleShowPerson).to receive(:high_scorers).with(now, 30).and_return([])
      allow(person).to receive(:first_guess)
      allow(person).to receive(:most_recent_guess)
      allow(person).to receive(:oldest_guess)
      allow(person).to receive(:fastest_guess)
      allow(person).to receive(:guess_of_longest_lasting_post)
      allow(person).to receive(:guess_of_shortest_lasting_post)
      allow(person).to receive(:guesses_with_associations).and_return([])
      allow(person).to receive(:favorite_posters).and_return([])
    end

    def stub_guesses
      allow(person).to receive(:mapped_guess_count).and_return(1)

      allow(PeopleShowPerson).to receive(:high_scorers).with(now, 7).and_return([person])
      allow(PeopleShowPerson).to receive(:high_scorers).with(now, 30).and_return([person])

      allow(person).to receive(:first_guess).and_return(build_stubbed :people_show_guess)
      allow(person).to receive(:most_recent_guess).and_return(build_stubbed :people_show_guess)
      allow(person).to receive(:oldest_guess).and_return(build_stubbed :people_show_guess, place: 1)
      allow(person).to receive(:fastest_guess).and_return(build_stubbed :people_show_guess, place: 1)

      allow(person).to receive(:guess_of_longest_lasting_post).and_return(build_stubbed :people_show_guess, place: 1)
      allow(person).to receive(:guess_of_shortest_lasting_post).and_return(build_stubbed :people_show_guess, place: 1)

      allow(person).to receive(:favorite_posters).and_return([favorite_poster])

      guess1 = build_stubbed :people_show_guess
      guess2 = build_stubbed :people_show_guess
      guess3 = build_stubbed :people_show_guess
      allow(guess3.photo).to receive(:person).and_return(guess2.photo.person)
      allow(person).to receive(:guesses_with_associations).and_return([guess1, guess2, guess3])

    end

    def stub_posts
      allow(person).to receive(:mapped_photo_count).and_return(1)

      allow(PeopleShowPerson).to receive(:top_posters).with(now, 7).and_return([person])
      allow(PeopleShowPerson).to receive(:top_posters).with(now, 30).and_return([person])

      first_post = build_stubbed :people_show_photo
      allow(person).to receive(:first_photo).and_return(first_post)

      most_recent_post = build_stubbed :people_show_photo
      allow(person).to receive(:most_recent_photo).and_return(most_recent_post)

      allow(person).to receive(:oldest_unfound_photo).and_return(build_stubbed :people_show_photo, place: 1)
      allow(person).to receive(:most_commented_photo).and_return(build_stubbed :people_show_photo, place: 1)
      allow(person).to receive(:most_viewed_photo).and_return(build_stubbed :people_show_photo, place: 1)
      allow(person).to receive(:most_faved_photo).and_return(build_stubbed :people_show_photo, place: 1)

      allow(person).to receive(:favoring_guessers).and_return([favoring_guesser])

      allow(person).to receive(:unfound_photos).and_return([build_stubbed(:people_show_photo)])
      allow(person).to receive(:revealed_photos).and_return([build_stubbed(:people_show_photo)])

      found1 = build_stubbed :people_show_guess
      allow(found1.photo).to receive(:guesses).and_return([found1])
      found2 = build_stubbed :people_show_guess
      allow(found2.photo).to receive(:guesses).and_return([found2])
      found3 = build_stubbed :people_show_guess, person: found2.person
      allow(found3.photo).to receive(:guesses).and_return([found3])
      allow(person).to receive(:photos_with_associations).and_return([found1.photo, found2.photo, found3.photo])

    end

    def renders_bits_for_user_who_has_guessed
      expect(response.body).to include "#{person.username} is in 1st place with a score of 3."
      expect(response.body).to include "#{person.username} scored the most points in the last week"
      expect(response.body).to include "#{person.username} scored the most points in the last month"

      expect(response.body).to have_css 'h2', text: "#{person.username} has correctly guessed 3 photos"
      expect(response.body).to have_link favorite_poster.username
      expect(response.body).to include "Of the photos that #{person.username} has guessed,"
      expect(response.body).to include "2 were posted by"
      expect(response.body).to include "1 was posted by"
    end

    def renders_bits_for_user_who_has_posted
      expect(response.body).to include "#{person.username} has posted 3 photos to the group, the most"
      expect(response.body).to include "#{person.username} posted the most photos in the last week"
      expect(response.body).to include "#{person.username} posted the most photos in the last month"

      expect(response.body).to have_css 'h2', text: "#{person.username} has posted 3 photos"
      expect(response.body).to have_link favoring_guesser.username
      expect(response.body).to include '1 remains unfound'
      expect(response.body).to include '1 was revealed'
      expect(response.body).to include '2 were guessed by'
      expect(response.body).to include '1 was guessed by'
    end

  end

  describe '#guesses' do
    it "renders the page" do
      guesser = build_stubbed :people_person
      allow(PeoplePerson).to receive(:find).with(guesser.id).and_return(guesser)
      poster = build_stubbed :people_person
      photo = build_stubbed :people_photo, person: poster
      allow(guesser).to receive(:guesses_with_associations_ordered_by_comments).
        and_return([build_stubbed(:people_guess, person: guesser, photo: photo)])
      get :guesses, id: guesser.id

      expect(response).to be_success
      expect(response.body).to have_css 'h1', text: '1 guess by username'
      expect(response.body).to have_link poster.username

    end
  end

  describe '#comments' do
    it "renders the page" do
      person = build_stubbed :people_person
      allow(PeoplePerson).to receive(:find).with(person.id).and_return(person)

      photo = build_stubbed :people_photo
      paginated_photos = [photo].paginate
      allow(person).to receive(:paginated_commented_photos).with('1').and_return(paginated_photos)

      get :comments, id: person.id, page: '1'

      expect(response).to be_success
      expect(response.body).to have_css 'h1', text: "1 photo commented on by #{person.username}"
      expect(response.body).to have_link 'Flickr', href: url_for_flickr_photo_in_pool(photo)
      expect(response.body).to have_link 'GWW', href: photo_path(photo)
      expect(response.body).to have_link photo.person.username, href: person_path(photo.person)

    end
  end

  describe '#map' do
    it "renders the page" do
      person = build_stubbed :people_show_person
      allow(PeoplePerson).to receive(:find).with(person.id).and_return(person)
      allow(PeopleShowPerson).to receive(:find).with(person.id).and_return(person)
      allow(person).to receive(:mapped_photo_count).and_return(1)
      allow(person).to receive(:mapped_guess_count).and_return(1)
      photos_json_data = { 'property' => 'value' }
      allow(PeoplePhoto).to receive(:for_person_for_map).
        with(person.id, PeopleController::INITIAL_MAP_BOUNDS, PeopleController::MAX_MAP_PHOTOS).and_return(photos_json_data)
      get :map, id: person.id

      expect(response).to be_success
      expect(response.body).to have_field 'posts'
      expect(response.body).to have_css 'label', text: '1 mapped post (?, -)'
      expect(response.body).to have_field 'guesses'
      expect(response.body).to have_css 'label', text: '1 mapped guess (!)'
      page_config = controller.with_google_maps_api_key(photos: photos_json_data)
      expect(response.body).to match(/GWW\.config = #{Regexp.escape page_config.to_json};/)

    end
  end

  describe '#map_json' do
    it "renders the page" do
      photos_json_data = { 'property' => 'value' }
      allow(PeoplePhoto).to receive(:for_person_for_map).
        with(1, PeopleController::INITIAL_MAP_BOUNDS, PeopleController::MAX_MAP_PHOTOS).and_return(photos_json_data)
      get :map_json, id: 1

      expect(response).to be_success
      expect(response.body).to eq(controller.with_google_maps_api_key(photos: photos_json_data).to_json)

    end

    it "supports arbitrary bounds" do
      allow(PeoplePhoto).to receive(:for_person_for_map).
        with(1, Bounds.new(0, 1, 10, 11), PeopleController::MAX_MAP_PHOTOS).and_return('property' => 'value')
      get :map_json, id: 1, sw: '0,10', ne: '1,11'
    end

  end

end
