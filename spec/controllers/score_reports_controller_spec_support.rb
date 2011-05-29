def renders_report_for(report_date, previous_report_date, action, params = {})
  person0 = Person.make
  person1 = Person.make
  person2 = Person.make
  person2[:change_in_standing] = 'guessed their first point. Congratulations!'

  guess11 = Guess.make 11, :person => person1
  guess21 = Guess.make 21, :person => person2
  guess22 = Guess.make 22, :person => person2
  stub(Guess).all_between(previous_report_date, report_date.getutc) { [guess11, guess21, guess22] }

  revealed_photo11 = Photo.make 11, :person => person1
  revealed_photo21 = Photo.make 21, :person => person2
  revealed_photo22 = Photo.make 22, :person => person2
  revelation11 = Revelation.make 11, :photo => revealed_photo11
  revelation21 = Revelation.make 21, :photo => revealed_photo21
  revelation22 = Revelation.make 22, :photo => revealed_photo22
  stub(Revelation).all_between(previous_report_date, report_date.getutc) { [revelation11, revelation21, revelation22] }

  stub(Person).high_scorers(report_date, 7) { [ person2, person1 ] }
  stub(Person).high_scorers(report_date, 30) { [ person2, person1 ] }

  stub(Person).top_posters(report_date, 7) { [ person2, person1 ] }
  stub(Person).top_posters(report_date, 30) { [ person2, person1 ] }

  stub(Photo).count_between(previous_report_date, report_date.getutc) { 6 }
  stub(Photo).unfound_or_unconfirmed_count_before(report_date) { 1234 }

  # Note that we're ignoring the test guesses' photos' people
  people = [ person0, person1, person2 ]
  stub(Person).all_before(report_date) { people }

  stub(Photo).add_posts(people, report_date, :posts)
  person0[:posts] = 0
  person1[:posts] = 1
  person2[:posts] = 2

  people_by_score = { 0 => [ person0 ], 1 => [ person1 ], 2 => [ person2 ] }
  stub(Person).by_score(people, report_date) { people_by_score }
  guessers = [ [ person2, [ guess21, guess22 ] ], [ person1, [ guess11 ] ] ]
  stub(Person).add_change_in_standings(people_by_score, people, previous_report_date, guessers) {}

  stub(FlickrUpdate).first { FlickrUpdate.make :member_count => 3 }

  get action, params

  #noinspection RubyResolve
  response.should be_success
  response.should have_selector 'b', :content => 'updated Wednesday, January  5, 12 AM'
  response.should contain /3 new guesses by .../
  response.should contain /guessed their first point/
  response.should contain /#{person2[:change_in_standing]}/
  response.should contain /3 photos revealed by .../
  response.should contain /Top guessers in the last week:/
  response.should contain /Top guessers in the last month:/
  response.should contain /Top posters in the last week:/
  response.should contain /Top posters in the last month:/
  response.should contain /6 photos have been added to the pool since the previous report/
  response.should have_selector 'a', :href => 'http://anythreewords.com/gwsf/', :content => '1234 unfound photos'
  # Doesn't see worth fixing the grammatical errors, since the numbers are always larger in production
  participation = '2 people have made correct guesses. ' +
    '1 people have put at least one photo in the pool but not guessed any photos correctly. ' +
    'That means that at least 3 of our 3 members have participated in the game.'
  response.should contain /#{participation}/
  guessing = "Since the beginning of the game, 1 people have guessed one photo correctly. " +
    "Here are the 1 people who've correctly guessed two or more photos."
  response.should contain /#{guessing}/

end
