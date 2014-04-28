FactoryGirl.define do
  factory :photo do
    association :person
    flickrid { "1#{rand 10000000000}" }
    farm { rand(10).to_s }
    server { rand(9999).to_s }
    secret { rand(2**40).to_s 16 }
    dateadded { Time.now }
    lastupdate { Time.now }
    seen_at { Time.now }
    game_status 'unfound'
    views 0
    faves 0
  end
end
