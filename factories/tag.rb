FactoryBot.define do
  factory :tag do
    association :photo, strategy: :build
    sequence(:raw) { |n| "tag#{n}" }
  end
end
