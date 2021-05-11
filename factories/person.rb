FactoryBot.define do
  sequence :person_sequence

  factory :person do
    transient do
      number { generate(:person_sequence) }
    end

    username { "username#{number}" }
    realname { "First Last#{number}" }
    flickrid { "#{rand 100000000}@N#{'%02d' % rand(10)}" }
    pathalias { username }
    ispro { false }
    photos_count { 0 }
  end

  {
    AdminPhotosPerson => [],
    PeopleIndexPerson => [],
    PeoplePerson => [:bias],
    PeopleShowPerson => %i(bias high_score top_post_count),
    PhotosSearchAutocompletionsPerson => [:photo_count],
    ScoreReportsPerson => %i(high_score top_post_count),
    StatisticsPerson => [],
    WheresiesPerson => []
  }.each do |specialist_class, traits|
    options = { parent: :person, class: specialist_class }
    if traits.any?
      options[:traits] = traits
    end
    factory specialist_class.name.underscore, options
  end

  trait :photo_count do
    transient do
      photo_count { nil }
    end

    after(:build) do |person, evaluator|
      if evaluator.photo_count
        person.define_singleton_method(:photo_count) do
          evaluator.photo_count
        end
      end
    end

  end

  trait :bias do
    transient do
      bias { nil }
    end

    after(:stub) do |person, evaluator|
      if evaluator.bias
        person.define_singleton_method(:bias) do
          evaluator.bias
        end
      end
    end

  end

  trait :high_score do
    transient do
      high_score { nil }
    end

    after(:stub) do |person, evaluator|
      if evaluator.high_score
        person.define_singleton_method(:high_score) do
          evaluator.high_score
        end
      end
    end

  end

  trait :top_post_count do
    transient do
      top_post_count { nil }
    end

    after(:stub) do |person, evaluator|
      if evaluator.top_post_count
        person.define_singleton_method(:top_post_count) do
          evaluator.top_post_count
        end
      end
    end

  end

end
