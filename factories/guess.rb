FactoryGirl.define do
  factory :guess do
    association :photo, strategy: :build
    association :person, strategy: :build
    sequence(:comment_text) { |n| "comment text #{n}" }
    commented_at { Time.now }
    added_at { Time.now }
  end
end
