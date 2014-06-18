FactoryGirl.define do
  factory :comment do
    association :photo, strategy: :build
    flickrid { "#{rand 100000000}@N#{"%02d" % rand(10)}" }
    username { "username#{generate :person_sequence}" }
    sequence(:comment_text) { |n| "comment text #{n}" }
    commented_at { Time.now }
  end
end
