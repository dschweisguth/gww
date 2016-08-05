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

  factory :wheresies_person, parent: :person, class: WheresiesPerson

end
