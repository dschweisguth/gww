FactoryBot.define do
  factory :revelation do
    association :photo, strategy: :build
    sequence(:comment_text) { |n| "comment text #{n}" }
    commented_at { Time.now }
    added_at { Time.now }
  end

  [AdminPhotosRevelation, ScoreReportsRevelation, StatisticsRevelation].each do |specialist_class|
    factory_name = specialist_class.name.underscore
    factory factory_name, parent: :revelation, class: specialist_class do
      association :photo, factory: factory_name.sub(/revelation$/, 'photo'), strategy: :build
    end
  end

end
