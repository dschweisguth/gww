FactoryGirl.define do
  factory :revelation do
    association :photo
    sequence(:comment_text) { |n| "comment text #{n}" }
    commented_at { Time.now }
    added_at { Time.now }
  end
end
