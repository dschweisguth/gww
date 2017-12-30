FactoryBot.define do
  factory :guess do
    association :photo, strategy: :build
    association :person, strategy: :build
    sequence(:comment_text) { |n| "comment text #{n}" }
    commented_at { Time.now }
    added_at { Time.now }
  end

  [AdminPhotosGuess, PeopleGuess, PeopleShowGuess, ScoreReportsGuess, StatisticsGuess, WheresiesGuess].each do |specialist_class|
    factory_name = specialist_class.name.underscore
    factory factory_name, parent: :guess, class: specialist_class do
      association :person, factory: factory_name.sub(/guess$/, 'person'), strategy: :build
      association :photo, factory: factory_name.sub(/guess$/, 'photo'), strategy: :build
    end
  end

end
