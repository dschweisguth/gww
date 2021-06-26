def renders_report_for(report_date, previous_report_date, action, params = {})
  person0 = build_stubbed :score_reports_person
  person1 = build_stubbed :score_reports_person, high_score: 1, top_post_count: 1
  person2 = build_stubbed :score_reports_person, high_score: 2, top_post_count: 2
  person2.change_in_standing = 'guessed their first point. Congratulations!'

  guess11 = build_stubbed :score_reports_guess, person: person1
  guess21 = build_stubbed :score_reports_guess, person: person2
  guess22 = build_stubbed :score_reports_guess, person: person2
  allow(ScoreReportsGuess).to receive(:all_between).with(previous_report_date, report_date.getutc) { [guess11, guess21, guess22] }

  revealed_photo11 = build_stubbed :score_reports_photo, person: person1
  revealed_photo21 = build_stubbed :score_reports_photo, person: person2
  revealed_photo22 = build_stubbed :score_reports_photo, person: person2
  revelation11 = build_stubbed :score_reports_revelation, photo: revealed_photo11
  revelation21 = build_stubbed :score_reports_revelation, photo: revealed_photo21
  revelation22 = build_stubbed :score_reports_revelation, photo: revealed_photo22
  allow(Revelation).to receive(:all_between).with(previous_report_date, report_date.getutc) { [revelation11, revelation21, revelation22] }

  allow(ScoreReportsPerson).to receive(:high_scorers).with(report_date, 7) { [person2, person1] }
  allow(ScoreReportsPerson).to receive(:high_scorers).with(report_date, 30) { [person2, person1] }

  allow(ScoreReportsPerson).to receive(:top_posters).with(report_date, 7) { [person2, person1] }
  allow(ScoreReportsPerson).to receive(:top_posters).with(report_date, 30) { [person2, person1] }

  allow(ScoreReportsPhoto).to receive(:count_between).with(previous_report_date, report_date.getutc) { 6 }
  allow(ScoreReportsPhoto).to receive(:unfound_or_unconfirmed_count_before).with(report_date) { 1234 }

  # Note that we're ignoring the test guesses' photos' people
  people = [person0, person1, person2]
  allow(ScoreReportsPerson).to receive(:all_before).with(report_date) { people }

  allow(ScoreReportsPhoto).to receive(:add_posts).with(people, report_date, :post_count)
  person0.post_count = 0
  person1.post_count = 1
  person2.post_count = 2

  people_by_score = { 0 => [person0], 1 => [person1], 2 => [person2] }
  allow(ScoreReportsPerson).to receive(:by_score).with(people, report_date) { people_by_score }
  guessers = [[person2, [guess21, guess22]], [person1, [guess11]]]
  allow(ScoreReportsPerson).to receive(:add_change_in_standings).with(people_by_score, people, previous_report_date, guessers) {}

  allow(FlickrUpdate).to receive(:latest) { build_stubbed :flickr_update, member_count: 3 }

  get action, params

  expect(response).to be_success
  expect(response.body).to have_css 'b', text: 'updated Wednesday, January  5, 12 AM'
  expect(response.body).to match(/3 new guesses by .../)
  expect(response.body).to match(/guessed their first point/)
  expect(response.body).to match(/#{person2.change_in_standing}/)
  expect(response.body).to match(/3 photos revealed by .../)
  expect(response.body).to match(/Top guessers in the last week:/)
  expect(response.body).to match(/Top guessers in the last month:/)
  expect(response.body).to match(/Top posters in the last week:/)
  expect(response.body).to match(/Top posters in the last month:/)
  expect(response.body).to match(/6 photos have been added to the pool since the previous report/)
  expect(response.body).to have_link '1234 unfound photos', href: search_photos_path('game-status/unfound,unconfirmed')
  # Doesn't see worth fixing the grammatical errors, since the numbers are always larger in production
  participation = '2 people have made correct guesses. ' \
    '1 people have put at least one photo in the pool but not guessed any photos correctly. ' \
    'That means that at least 3 of our 3 members have participated in the game.'
  expect(response.body).to match(/#{participation}/)
  guessing = "Since the beginning of the game, 1 people have guessed one photo correctly. " \
    "Here are the 1 people who've correctly guessed two or more photos."
  expect(response.body).to match(/#{guessing}/)

end
