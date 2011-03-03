require 'spec_helper'

describe Admin::ScoreReportsController do
  integrate_views

  describe '#index' do
    it "renders the page" do
      stub(ScoreReport).all { [
        ScoreReport.make(:created_at => Time.local(2011, 1, 2)),
        ScoreReport.make(:created_at => Time.local(2011))
      ] }
      get :index
      #noinspection RubyResolve
      response.should be_success
      # By experiment, this doesn't actually assert that the form is in the
      # same tr as the later date!?!
      response.should have_tag 'tr' do
        with_tag 'td', :text => 'January  2, 2011 12:00:00 AM'
        with_tag 'form'
      end
      response.should have_tag 'tr' do
        with_tag 'td', :text => 'January  1, 2011 12:00:00 AM'
      end
    end

    it "doesn't allow deletion of the last report" do
      stub(ScoreReport).all { [ ScoreReport.make :created_at => Time.local(2011) ] }
      get :index
      #noinspection RubyResolve
      response.should be_success
      response.should_not have_tag 'form'
    end

  end

  describe '#new' do
    it 'renders the page' do
      report_date = Time.local(2011, 1, 5)
      stub(Time).now { report_date }

      previous_report = ScoreReport.make :created_at => Time.local(2011)
      stub(ScoreReport).preceding(report_date) { previous_report }

      person0 = Person.make
      person1 = Person.make
      person2 = Person.make

      guess11 = Guess.make 11, :person => person1
      guess21 = Guess.make 21, :person => person2
      guess22 = Guess.make 22, :person => person2
      mock(Guess).all_between(previous_report.created_at, report_date.getutc) { [ guess11, guess21, guess22 ] }

      revealed_photo11 = Photo.make 11, :person => person1
      revealed_photo21 = Photo.make 21, :person => person2
      revealed_photo22 = Photo.make 22, :person => person2
      revelation11 = Revelation.make 11, :photo => revealed_photo11
      revelation21 = Revelation.make 21, :photo => revealed_photo21
      revelation22 = Revelation.make 22,  :photo => revealed_photo22
      mock(Revelation).all_between(previous_report.created_at, report_date.getutc) { [ revelation11, revelation21, revelation22 ] }

      stub(Person).high_scorers(7) { [ person2, person1 ] }
      stub(Person).high_scorers(30) { [ person2, person1 ] }

      mock(Photo).count_between(previous_report.created_at, report_date.getutc) { 6 }
      mock(Photo).unfound_or_unconfirmed_count { 1234 }

      # Note that we're ignoring the test guesses' photos' people
      people = [ person0, person1, person2 ]
      stub(Person).all { people }

      mock(Photo).add_posts(people)
      person0[:posts] = 0
      person1[:posts] = 1
      person2[:posts] = 2

      mock(Person).by_score(people) { { 0 => [ person0 ], 1 => [ person1 ], 2 => [ person2 ] } }

      stub(FlickrUpdate).first { FlickrUpdate.make :member_count => 3 }

      get :new

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'strong', :text => 'updated Wednesday, January 05, 12 AM'
      response.should have_text /3 new guesses by .../
      response.should have_text /3 photos revealed by .../
      response.should have_text /Top guessers in the last week:/
      response.should have_text /Top guessers in the last month:/
      response.should have_text /6 photos have been added to the pool since the previous report/
      response.should have_tag 'a[href=http://anythreewords.com/gwsf/]', :text => '1234 unfound photos'
      # Doesn't see worth fixing the grammatical errors, since the numbers are always larger in production
      participation = '2 people have made correct guesses. ' +
        '1 people have put at least one photo in the pool but not guessed any photos correctly. ' +
        'That means that at least 3 of our 3 members have participated in the game.'
      response.should have_text /#{participation}/
      guessing = "Since the beginning of the game, 1 people have guessed one photo correctly. " +
        "Here are the 1 people who've correctly guessed two or more photos."
      response.should have_text /#{guessing}/

    end
  end

  describe '#create' do
    it "creates and redirects" do
      mock(ScoreReport).create!
      post :create
      response.should redirect_to :controller => 'admin/score_reports', :action => 'new'
    end
  end

  describe '#destroy' do
    it "destroys and redirects" do
      mock(ScoreReport).destroy('666')
      get :destroy, :id => 666
      #noinspection RubyResolve
      response.should redirect_to score_reports_path
    end
  end

end
