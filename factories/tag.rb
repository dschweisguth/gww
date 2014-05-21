FactoryGirl.define do
  factory :tag do
    association :photo
    sequence(:raw) { |n| "tag#{n}" }
  end
end
