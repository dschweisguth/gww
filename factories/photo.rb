FactoryGirl.define do
  factory :photo do
    association :person, strategy: :build
    flickrid { "1#{rand 10000000000}" }
    farm { rand(10).to_s }
    server { rand(9999).to_s }
    secret { rand(2**40).to_s 16 }
    dateadded { Time.now }
    lastupdate { Time.now }
    seen_at { Time.now }
    game_status 'unfound'
    views 0
    sequence(:title) { |n| "Title #{n}" }
    sequence(:description) { |n| "Description #{n}" }
    faves 0
  end

  factory :score_reports_photo, parent: :photo, class: ScoreReportsPhoto do
    association :person, factory: :score_reports_person, strategy: :build
  end

  factory :wheresies_photo, parent: :photo, class: WheresiesPhoto do
    association :person, factory: :wheresies_person, strategy: :build
  end

end
