FactoryGirl.define do
  sequence :person_sequence

  factory :person do
    transient do
      number { generate(:person_sequence) }
    end

    username { "username#{number}" }
    realname { "First Last#{number}" }
    flickrid { "#{rand 100000000}@N#{'%02d' % rand(10)}" }
    pathalias { username }
  end

  factory :people_person, parent: :person, class: PeoplePerson
  factory :people_index_person, parent: :person, class: PeopleIndexPerson
  factory :people_show_person, parent: :person, class: PeopleShowPerson
  factory :score_reports_person, parent: :person, class: ScoreReportsPerson
  factory :wheresies_person, parent: :person, class: WheresiesPerson

end
