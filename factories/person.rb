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

  {
    photo_count: :build,
    bias: :stub,
    high_score: :stub,
    top_post_count: :stub
  }.each do |trait_name, callback|
    trait trait_name do
      transient do
        send trait_name, nil
      end

      after(callback) do |person, evaluator|
        if evaluator.send trait_name
          person.define_singleton_method(trait_name) do
            evaluator.send trait_name
          end
        end
      end

    end
  end

end
