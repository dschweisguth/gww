FactoryGirl.define do
  factory :revelation do
    association :photo, strategy: :build
    sequence(:comment_text) { |n| "comment text #{n}" }
    commented_at { Time.now }
    added_at { Time.now }
  end

  factory :score_reports_revelation, parent: :revelation, class: ScoreReportsRevelation do
    association :photo, factory: :score_reports_photo, strategy: :build
  end

end
