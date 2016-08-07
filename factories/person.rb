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

  [PeoplePerson, PeopleIndexPerson, PeopleShowPerson, ScoreReportsPerson, WheresiesPerson].each do |specialist_class|
    factory specialist_class.name.underscore, parent: :person, class: specialist_class
  end

end
