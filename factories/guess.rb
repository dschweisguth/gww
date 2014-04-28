FactoryGirl.define do
  factory :guess do
    association :photo
    association :person
    sequence(:comment_text) { |n| "comment text #{n}" }
    commented_at { Time.now }
    added_at { Time.now }
  end
end
