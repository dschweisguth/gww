FactoryGirl.define do
  factory :revelation do
    association :photo, strategy: :build
    sequence(:comment_text) { |n| "comment text #{n}" }
    commented_at { Time.now }
    added_at { Time.now }
  end
end
