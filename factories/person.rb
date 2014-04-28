FactoryGirl.define do
  factory :person do
    sequence(:username) { |n| "username#{n}" }
    flickrid { "#{rand 100000000}@N#{"%02d" % rand(10)}" }
    pathalias { username }
  end
end
