FactoryGirl.define do
  sequence :person_sequence

  factory :person do
    username { "username#{generate :person_sequence}" }
    flickrid { "#{rand 100000000}@N#{'%02d' % rand(10)}" }
    pathalias { username }
  end

end
